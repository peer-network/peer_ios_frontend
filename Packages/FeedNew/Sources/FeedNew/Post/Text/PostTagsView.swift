//
//  PostTagsView.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
//

import SwiftUI
import Environment

struct PostTagsView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var postVM: PostViewModel
    
    var tags: [String] {
        postVM.post.tags.map { "#\($0)"}
    }

    var body: some View {
        if !postVM.post.tags.isEmpty {
            Text(tags.joined(separator: " "))
                .font(.customFont(weight: .regular, size: .footnote))
                .foregroundStyle(Color.hashtag)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
