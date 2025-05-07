//
//  RowUserView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 07.05.25.
//

import Models
import SwiftUI

public struct RowUserView: View {
    private let user: RowUser

    public init(user: RowUser) {
        self.user = user
    }

    public var body: some View {
        HStack(spacing: 0) {
            ProfileAvatarView(url: user.imageURL, name: user.username, config: .rowUser)
                .padding(.trailing, 10)

            Text(user.username)
                .font(.customFont(weight: .boldItalic, style: .callout))
                .padding(.trailing, 5)

            Text("#\(String(user.slug))")
                .opacity(0.5)
        }
        .font(.customFont(weight: .regular, style: .footnote))
        .foregroundStyle(Colors.whitePrimary)
    }
}
