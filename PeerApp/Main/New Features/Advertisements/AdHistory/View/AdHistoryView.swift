//
//  AdHistoryView.swift
//  PeerApp
//
//  Created by Artem Vasin on 16.10.25.
//

import SwiftUI
import DesignSystem
import Environment
import Models

struct AdHistoryView: View {
    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Profile")
        } content: {
            content
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                earningsView
                    .padding(.bottom, 10)

                spendingsView
                    .padding(.bottom, 20)

                Text("Interactions")
                    .appFont(.bodyRegular)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                interactionsCounterView
                    .padding(.bottom, 20)

                allAdsTitleView
                    .padding(.bottom, 18)

                listAdsView
            }
            .foregroundStyle(Colors.whitePrimary)
            .padding(20)
        }
        .scrollIndicators(.hidden)
    }

    private var earningsView: some View {
        HStack(spacing: 0) {
            Text("Earnings")
                .appFont(.bodyRegular)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            HStack(spacing: 5) {
                Icons.gem
                    .iconSize(height: 19)

                Text(25566, format: .number)
                    .appFont(.largeTitleBold)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(Colors.inactiveDark)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }

    private var spendingsView: some View {
        HStack(spacing: 0) {
            Text("Spendings")
                .appFont(.bodyRegular)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            HStack(spacing: 5) {
                Text(10000, format: .number)
                    .appFont(.bodyBold)

                Icons.logoCircleWhite
                    .iconSize(height: 15)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .modifier(RoundedShapeModifier())
    }

    private var interactionsCounterView: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer()
                .overlay {
                    interactionView(icon: Icons.heart, name: "Likes", count: 300000)
                }

            separatorView

            Spacer()
                .overlay {
                    interactionView(icon: Icons.heartBroke, name: "Dislikes", count: 300000)
                }

            separatorView

            Spacer()
                .overlay {
                    interactionView(icon: Icons.bubble, name: "Comments", count: 300000)
                }

            separatorView

            Spacer()
                .overlay {
                    interactionView(icon: Icons.eyeCircled, name: "Views", count: 300000)
                }

            separatorView

            Spacer()
                .overlay {
                    interactionView(icon: Icons.heart, name: "Reports", count: 219)
                }
        }
        .padding(.horizontal, 10)
        .frame(height: 100)
        .modifier(RoundedShapeModifier())
        .lineLimit(1)
    }

    private var separatorView: some View {
        HStack(spacing: 0) {
            Capsule()
                .frame(width: 1, height: 45)
                .foregroundStyle(Colors.whiteSecondary)
        }
    }

    private func interactionView(icon: Image, name: String, count: Int) -> some View {
        VStack(spacing: 0) {
            icon
                .iconSize(height: 15.56)
                .padding(.bottom, 5)

            Text(name)
                .appFont(.smallLabelRegular)
                .padding(.bottom, 10)

            Text(count, format: .number.notation(.compactName))
                .appFont(.bodyBold)
                .foregroundStyle(Colors.whitePrimary)
        }
        .foregroundStyle(Colors.whiteSecondary)
    }

    private struct RoundedShapeModifier: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(Colors.inactiveDark)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }

    private var allAdsTitleView: some View {
        HStack(spacing: 0) {
            Text("All advertisements")
                .appFont(.bodyRegular)

            Spacer()
                .frame(minWidth: 10)
                .frame(maxWidth: .infinity)
                .layoutPriority(-1)

            Text("Total: \(4)")
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whiteSecondary)
        }
    }

    private var listAdsView: some View {
        VStack(spacing: 10) {
            ForEach(0..<4) { _ in
                RowPostView(post: .placeholdersImage(count: 1).first!)
            }
        }
    }
}

#Preview {
    AdHistoryView()
        .environmentObject(Router())
        .environmentObject(AccountManager.shared)
}
