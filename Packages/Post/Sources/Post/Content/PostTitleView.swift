//
//  PostTitleView.swift
//  Post
//
//  Created by Artem Vasin on 11.02.26.
//

import SwiftUI
import DesignSystem

struct PostTitleView: View {
    @ObservedObject var postVM: PostViewModel

    var body: some View {
        titleTextView
            .appFont(.bodyBold)
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var titleTextView: Text {
        if let attributedTitle = postVM.attributedTitle {
            return Text(attributedTitle)
        } else {
            return Text(postVM.post.title)
        }
    }
}
