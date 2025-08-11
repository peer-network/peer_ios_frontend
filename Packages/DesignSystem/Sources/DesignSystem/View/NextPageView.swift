//
//  NextPageView.swift
//  DesignSystem
//
//  Created by Артем Васин on 02.01.25.
//

import SwiftUI
import SFSafeSymbols

@MainActor
public struct NextPageView: View {
    @State private var isLoadingNextPage: Bool = false
    @State private var showRetry: Bool = false
    
    let loadNextPage: () async throws -> Void
    
    public init(loadNextPage: @escaping (() async throws -> Void)) {
        self.loadNextPage = loadNextPage
    }
    
    public var body: some View {
        HStack {
            if showRetry {
                Button {
                    Task {
                        showRetry = false
                        await executeTask()
                    }
                } label: {
                    Label("Retry", systemSymbol: .arrowClockwise)
                }
                .buttonStyle(.bordered)
            } else {
                Label("Loading...", systemSymbol: .arrowDown)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .task {
            await executeTask()
        }
        .listRowSeparator(.hidden, edges: .all)
    }
    
    private func executeTask() async {
        showRetry = false
        defer {
            isLoadingNextPage = false
        }
        guard !isLoadingNextPage else { return }
        isLoadingNextPage = true
        do {
            try await loadNextPage()
        } catch {
            showRetry = true
        }
    }
}

#Preview {
    List {
        Text("Item 1")
        NextPageView {}
    }
    .listStyle(.plain)
}
