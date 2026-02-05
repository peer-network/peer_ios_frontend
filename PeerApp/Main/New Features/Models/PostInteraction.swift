//
//  PostInteraction.swift
//  PeerApp
//
//  Created by Artem Vasin on 03.02.26.
//

enum PostInteraction {
    case likes, dislikes, views

    var stringValue: String {
        switch self {
            case .likes: "likes"
            case .dislikes: "dislikes"
            case .views: "views"
        }
    }
}
