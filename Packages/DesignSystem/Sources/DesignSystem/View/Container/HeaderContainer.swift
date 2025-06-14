//
//  HeaderContainer.swift
//  DesignSystem
//
//  Created by Артем Васин on 11.02.25.
//

import SwiftUI
import Environment

public struct HeaderContainer<Header: View, Content: View>: View {
    @frozen
    public enum ActionsToDisplay {
        case commentsAndLikes
        case posts
    }

    @EnvironmentObject private var router: Router
    @EnvironmentObject private var accountManager: AccountManager

    private let header: () -> Header
    private let content: () -> Content
    private let actionsToDisplay: ActionsToDisplay

    @State private var showPopover = false

    public init(
        actionsToDisplay: ActionsToDisplay,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.actionsToDisplay = actionsToDisplay
        self.header = header
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                if !router.path.isEmpty {
                    Button {
                        router.path.removeLast()
                    } label: {
                        Icons.arrowDown
                            .iconSize(height: 7)
                            .rotationEffect(.degrees(90))
                            .padding(.leading, 20)
                            .padding(.trailing, 10)
                    }
                    .contentShape(.rect)
                } else {
                    Spacer()
                        .frame(width: 20)
                }

                header()
                    .font(.customFont(weight: .regular, size: .title))

                Spacer()

                HStack(alignment: .center, spacing: 15) {
                    switch actionsToDisplay {
                        case .commentsAndLikes:
                            HStack(alignment: .center, spacing: 5) {
                                Icons.bubbleFill
                                    .iconSize(height: 10)

                                Text("\(accountManager.dailyFreeComments)")
                            }

                            HStack(alignment: .center, spacing: 5) {
                                Icons.heartFill
                                    .iconSize(height: 10)

                                Text("\(accountManager.dailyFreeLikes)")
                            }

                            HStack(alignment: .center, spacing: 5) {
                                Icons.plustSquare
                                    .iconSize(height: 13)

                                Text("\(accountManager.dailyFreePosts)")
                            }
                        case .posts:
                            HStack(alignment: .center, spacing: 5) {
                                Icons.plustSquare
                                    .iconSize(height: 13)

                                Text("\(accountManager.dailyFreePosts)")
                            }
                    }
                }
                .font(.customFont(weight: .regular, size: .body))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Colors.inactiveDark)
                .clipShape(RoundedRectangle(cornerRadius: 34))
                .contentShape(.rect)
                .onTapGesture {
                    showPopover = true
                }
                .popover(isPresented: $showPopover, arrowEdge: .top) {
                    Text("Your daily free actions")
                        .font(.customFont(weight: .regular, style: .footnote))
                        .padding()
                        .presentationBackground(.ultraThinMaterial)
                        .presentationCompactAdaptation(.popover)
                }

                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Button {
                        if router.path.last != .versionHistory {
                            router.navigate(to: .versionHistory)
                        }
                    } label: {
                        Text("v. \(Text(version).font(.customFont(weight: .semiBold, size: .body)))")
                            .font(.customFont(weight: .regular, size: .body))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Colors.inactiveDark)
                            .clipShape(RoundedRectangle(cornerRadius: 34))
                            .contentShape(.rect)
                    }
                    .padding(.leading, 10)
                }
            }
            .foregroundStyle(Colors.whitePrimary)
            .padding(.vertical, 10)
            .padding(.trailing, 20)

            content()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Colors.textActive.ignoresSafeArea())
    }
}
