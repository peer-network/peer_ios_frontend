//
//  VersionHistoryView.swift
//  VersionHistory
//
//  Created by Artem Vasin on 11.04.25.
//

import SwiftUI
import DesignSystem
import Environment
import Analytics

public struct VersionHistoryView: View {
    @Environment(\.analytics) private var analytics
    @Environment(\.openURL) private var openURL

    @StateObject private var viewModel: VersionHistoryViewModel

    private let appWikiURL = URL(string: "https://github.com/peer-network/peer_ios_frontend/wiki")!
    private let backendWikiURL = URL(string: "https://github.com/peer-network/peer_backend/wiki")!

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
                            .controlSize(.large)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                    case .loaded(let items):
                        VStack(spacing: 20) {
                            wikiButtons

                            versionHistoryList(items)
                        }
                        .padding(.top, 10)

                    case .error(let error):
                        ErrorView(title: "We were not able to load version history.", description: error.localizedDescription) {
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
        .trackScreen(AppScreen.versionHistory)
    }

    private var wikiButtons: some View {
        HStack(spacing: 16) {
            Button {
                openURL(appWikiURL)
            } label: {
                Text("App Wiki")
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                    }
            }

            Button {
                openURL(backendWikiURL)
            } label: {
                Text("Backend Wiki")
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                    }
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .font(.customFont(weight: .regular, size: .body))
        .padding(.horizontal, 20)
    }

    private func versionHistoryList(_ items: [VersionHistoryItem]) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ForEach(items) { item in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 0) {
                            Text(item.version)
                                .font(.customFont(weight: .bold, size: .title))

                            Spacer()
                                .frame(minWidth: 16)

                            Text(item.date)
                                .opacity(0.5)
                        }

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
            .padding(.horizontal, 20)
        }
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
