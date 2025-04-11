//
//  VersionHistoryView.swift
//  VersionHistory
//
//  Created by Artem Vasin on 11.04.25.
//

import SwiftUI
import DesignSystem
import Environment

public struct VersionHistoryView: View {
    @StateObject private var viewModel: VersionHistoryViewModel

    public init(service: VersionHistoryServiceProtocol = LocalVersionHistoryService()) {
        _viewModel = StateObject(wrappedValue: VersionHistoryViewModel(service: service))
    }

    public var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Version History")
        } content: {
            Group {
                switch viewModel.state {
                    case .idle, .loading:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    case .loaded(let items):
                        versionHistoryList(items)

                    case .error(let error):
                        ErrorView(title: "We are not able to load version history.", description: error.localizedDescription) {
                            Task {
                                await viewModel.loadVersionHistory()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .task {
                await viewModel.loadVersionHistory()
            }
        }
    }

    private func versionHistoryList(_ items: [VersionHistoryItem]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(item.version)
                            .font(.customFont(weight: .bold, size: .title))

                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(item.releaseNotes, id: \.self) { note in
                                Text("• \(note)")
                            }
                        }
                    }

                    if item.id != items.last?.id {
                        Rectangle()
                            .frame(height: 1)
                            .opacity(0.5)
                    }
                }
            }
        }
        .padding(20)
        .foregroundStyle(Colors.whitePrimary)
        .font(.customFont(weight: .regular, size: .body))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VersionHistoryView(service: MockVersionHistoryService())
        .environmentObject(Router())
        .environmentObject(AccountManager.shared)
}
