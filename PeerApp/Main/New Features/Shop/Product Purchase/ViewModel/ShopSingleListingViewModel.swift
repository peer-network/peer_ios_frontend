//
//  ShopSingleListingViewModel.swift
//  PeerApp
//
//  Created by Artem Vasin on 28.01.26.
//

import SwiftUI
import Models

@MainActor
final class ShopSingleListingViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case ready(ShopListing)
        case missing
        case error(String)
    }

    @Published private(set) var state: State = .loading

    private let repo: ShopItemRepository
    private var task: Task<Void, Never>?

    init(repo: ShopItemRepository) {
        self.repo = repo
    }

    func load(post: Post) {
        task?.cancel()
        state = .loading

        task = Task {
            do {
                let item = try await repo.fetchItem(postID: post.id)
                guard let item else {
                    state = .missing
                    return
                }
                state = .ready(ShopListing(post: post, item: item))
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }

    deinit { task?.cancel() }
}
