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
    private let dismissAction: (() -> Void)?

    private var profileImageIgnoreCache: Bool {
        AccountManager.shared.isCurrentUser(id: user.id)
    }

    @State private var showSensitiveContentWarning: Bool = false

    public init(user: RowUser, @ViewBuilder trailingContent: @escaping () -> TrailingContent = { EmptyView() }, dismissAction: (() -> Void)? = nil) {
        self.user = user
        showSensitiveContentWarning = user.visibilityStatus == .hidden
        self.trailingContent = trailingContent
        self.dismissAction = dismissAction
    }

    public var body: some View {
        HStack(spacing: 0) {
            Button {
                dismissAction?()
                router.presentedSheet = nil
                router.navigate(to: .accountDetail(id: user.id))
            } label: {
                HStack(spacing: 0) {
                    if user.visibilityStatus == .illegal {
                        Circle()
                            .foregroundStyle(Colors.inactiveDark)
                            .frame(height: 40)
                            .overlay {
                                IconsNew.exclamaitionMarkCircle
                                    .iconSize(height: 16)
                                    .foregroundStyle(Colors.whiteSecondary)
                            }
                        .padding(.trailing, 10)
                    } else {
                        ProfileAvatarView(url: user.imageURL, name: user.username, config: .rowUser, ignoreCache: profileImageIgnoreCache)
                            .padding(.trailing, 10)
                    }

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
            .ifCondition(showSensitiveContentWarning) {
                $0
                    .allowsHitTesting(false)
                    .blur(radius: 5)
                    .overlay(alignment: .leading) {
                        Button {
                            withAnimation {
                                showSensitiveContentWarning = false
                            }
                        } label: {
                            sensitiveContentWarningForPostHeaderView
                                .contentShape(.rect)
                        }
                    }
            }

            Spacer()

            Spacer(minLength: 10)

            if redactionReasons != .placeholder, !AccountManager.shared.isCurrentUser(id: user.id) {
                trailingContent()
            }
        }
    }

    private var sensitiveContentWarningForPostHeaderView: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(height: 40)
                .foregroundStyle(Colors.whitePrimary.opacity(0.2))
                .overlay {
                    IconsNew.eyeWithSlash
                        .iconSize(width: 20)
                        .foregroundStyle(Colors.whitePrimary)
                }

            VStack(alignment: .leading, spacing: 0) {
                Text("Sensitive content")
                    .appFont(.smallLabelBold)

                Text("Click to see")
                    .appFont(.smallLabelRegular)
            }
        }
        .foregroundStyle(Colors.whitePrimary)
        .fixedSize(horizontal: true, vertical: false)
    }
}
