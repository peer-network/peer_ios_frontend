//
//  TextPostCreatorView.swift
//  PostCreation
//
//  Created by Артем Васин on 14.02.25.
//

import SwiftUI
import DesignSystem

struct TextPostCreatorView: View {
    @Binding var title: String
    @Binding var text: String

    var body: some View {
        VStack(spacing: 10) {
//            PostHeaderView()
//                .redacted(reason: .placeholder)
//                .environmentObject(PostViewModel(post: .placeholderText()))

            PostTextField(placeholder: "Write a title...", text: $title)
                .bold()

            // TODO: Move symbols limit in a title and post to Constants
            PostTextField(placeholder: "Write a post...", text: $text, symbolsLimit: 250, reserveLinesSpace: true)
        }
        .padding(20)
        .background(Colors.whitePrimary)
        .cornerRadius(24)
    }
}

private struct PostTextField: View {
    let placeholder: String
    let text: Binding<String>
    let symbolsLimit: Int?
    let reserveLinesSpace: Bool

    init(placeholder: String, text: Binding<String>, symbolsLimit: Int? = nil, reserveLinesSpace: Bool = false) {
        self.placeholder = placeholder
        self.text = text
        self.symbolsLimit = symbolsLimit
        self.reserveLinesSpace = reserveLinesSpace
    }

    var body: some View {
        VStack(spacing: 10) {
            TextField(text: text, axis: .vertical) {
                Text(placeholder)
                    .foregroundStyle(Colors.textSuggestions)
            }
            .lineLimit(5, reservesSpace: reserveLinesSpace)

            if let symbolsLimit {
                Text("\(text.wrappedValue.count)/\(symbolsLimit)")
                    .foregroundStyle(Colors.textSuggestions)
                    .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .font(.customFont(weight: .regular, size: .footnote))
        .foregroundStyle(Colors.textActive)
        .background(Colors.blueLight)
        .cornerRadius(24)
        .contentShape(Rectangle())
    }
}


#Preview {
    TextPostCreatorView(title: .constant("Title here"), text: .constant("Text here"))
        .padding()
        .background(Colors.textActive)
}
