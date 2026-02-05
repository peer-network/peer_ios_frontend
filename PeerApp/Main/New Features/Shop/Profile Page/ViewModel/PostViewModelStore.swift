//
//  PostViewModelStore.swift
//  PeerApp
//
//  Created by Artem Vasin on 05.02.26.
//

import SwiftUI
import Post
import Environment
import Models

@MainActor
final class PostViewModelStore: ObservableObject {
    private var cache: [String: PostViewModel] = [:]

    func viewModel(for listing: ShopListing, apiService: APIService?) -> PostViewModel {
        let id = listing.id

        if let vm = cache[id] {
            vm.apiService = apiService
            return vm
        }

        let vm = PostViewModel(post: listing.post)
        vm.apiService = apiService
        cache[id] = vm
        return vm
    }

    func reset() {
        cache.removeAll()
    }

    func prune(keeping ids: Set<String>) {
        cache.keys
            .filter { !ids.contains($0) }
            .forEach { cache.removeValue(forKey: $0) }
    }
}
