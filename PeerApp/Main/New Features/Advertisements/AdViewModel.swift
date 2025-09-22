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

    init(post: Post) {
        self.post = post
    }
}
