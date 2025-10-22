//
//  AdViewModel.swift
//  PeerApp
//
//  Created by Artem Vasin on 09.09.25.
//

import Combine
import Models

final class AdViewModel: ObservableObject {
    let post: Post
    let pinAdvertisementPrice: Int

    var hasEnoughTokens: Bool {
        // TODO: Add logic
        return true
    }

    init(post: Post, pinAdvertisementPrice: Int) {
        self.post = post
        self.pinAdvertisementPrice = pinAdvertisementPrice
    }
}
