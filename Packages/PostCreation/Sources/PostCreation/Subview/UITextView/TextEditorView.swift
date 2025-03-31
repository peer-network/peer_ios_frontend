//
//  TextEditorView.swift
//  PostCreation
//
//  Created by Artem Vasin on 12.03.25.
//

import SwiftUI
import Environment

struct TextEditorView: View {
    @EnvironmentObject private var viewModel: PostCreationViewModel
    @EnvironmentObject private var accountManager: AccountManager

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if let user = accountManager.user {
                Text(user.username)
                    .bold()
                    .italic()
                    .foregroundStyle(Color.white)
                    .frame(width: (getRect().width - 20) * 0.2, alignment: .topLeading)

                VStack(alignment: .leading, spacing: 20) {
                    TextField(text: $viewModel.postTitle, axis: .vertical) {
                        Text("Write a title to your publication...")
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .keyboardType(.default)
                    .bold()

                    TextView($viewModel.postText) { textView in
                        viewModel.textView = textView
                    }
                    .placeholder("Write a caption...")
                    .setKeyboardType(.default)
                }
            }
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .multilineTextAlignment(.leading)
    }
}
