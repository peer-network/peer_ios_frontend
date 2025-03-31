//
//  ReelLike.swift
//  FeedNew
//
//  Created by Артем Васин on 07.02.25.
//

import Foundation

struct ReelLike: Identifiable {
    var id: UUID = .init()
    var tappedRect: CGPoint = .zero
    var isAnimated: Bool = false
}
