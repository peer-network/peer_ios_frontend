//
//  RowProfileView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 04.08.25.
//

import SwiftUI
import Models
import Environment

public struct RowProfileView<TrailingContent: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var apiManager: APIServiceManager
    @Environment(\.redactionReasons) private var redactionReasons

    private let user: RowUser
    private let trailingContent: () -> TrailingContent

    private var profileImageIgnoreCache: Bool {
        AccountManager.shared.isCurrentUser(id: user.id)
    }

    enum TrailingContent {
        case unblockButton
        case followButton
    }

    public init(user: RowUser, @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }) {
        self.user = user
        self.trailingContent = trailingContent
    }

    public var body: some View {
        HStack(spacing: 0) {
            Button {
//                dismiss() // TODO: FIX THIS ONE
                router.presentedSheet = nil
                router.navigate(to: .accountDetail(id: user.id))
            } label: {
                HStack(spacing: 0) {
                    ProfileAvatarView(url: user.imageURL, name: user.username, config: .rowUser, ignoreCache: profileImageIgnoreCache)
                        .padding(.trailing, 10)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(user.username)
                            .font(.customFont(weight: .boldItalic, style: .callout))
                            .lineLimit(1)
                            .padding(.trailing, 5)

                        Text("#\(String(user.slug))")
                            .foregroundStyle(Colors.whiteSecondary)
                    }
                }
                .lineLimit(1)
                .contentShape(Rectangle())
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.customFont(weight: .regular, style: .footnote))
            .foregroundStyle(Colors.whitePrimary)
            .simultaneousGesture(TapGesture())

            Spacer()

            Spacer(minLength: 10)

            if redactionReasons != .placeholder, !AccountManager.shared.isCurrentUser(id: user.id) {
                trailingContent()
            }
        }
    }
}
