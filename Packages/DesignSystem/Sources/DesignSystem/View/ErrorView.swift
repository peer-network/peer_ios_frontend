//
//  ErrorView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 11.04.25.
//

import SwiftUI

public struct ErrorView: View {
    private let title: String
    private let description: String?
    private let action: (() -> Void)?

    public init(title: String, description: String?, action: (() -> Void)? = nil) {
        self.title = title
        self.description = description
        self.action = action
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Icons.exclamationMarkTriangleBlack
                .iconSize(height: 85)

            Text(title)

            if let description {
                Text(description)
            }

            if let action {
                Button {
                    action()
                } label: {
                    HStack(spacing: 20) {
                        Text("Retry")

                        Icons.arrowCounterClockwise
                            .iconSize(height: 16)
                    }
                    .padding(.vertical, 10)
                    .frame(width: 176)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Colors.whitePrimary, lineWidth: 1)
                    }
                }
                .padding(.top, 10)
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .font(.customFont(weight: .regular, style: .footnote))
        .multilineTextAlignment(.center)
    }
}

#Preview {
    ErrorView(title: "We are not able to load the feed. Please, check the connection and try again.", description: "Something bad happened") {
        print("123")
    }
        .background(Colors.textActive)
}
