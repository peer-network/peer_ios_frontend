//
//  ShopFAQView.swift
//  PeerApp
//
//  Created by Artem Vasin on 13.01.26.
//

import SwiftUI
import DesignSystem

struct ShopFAQView: View {
    let dismiss: () -> Void

    private struct Section: Identifiable {
        let id = UUID()
        let title: String
        let lines: [Line]
        let bottomSpacing: CGFloat

        struct Line: Identifiable {
            let id = UUID()
            let text: Text
            var isTitle: Bool = false
            var bottomSpacing: CGFloat = 0
        }
    }

    private var sections: [Section] {
        [
            .init(
                title: "Order Processing",
                lines: [
                    .init(text: Text("Your order is processed as soon as your payment is confirmed. You’ll receive a confirmation email with delivery details within 1–3 days."))
                ],
                bottomSpacing: 20
            ),
            .init(
                title: "Delivery information & time",
                lines: [
                    .init(text: Text("• Delivery costs are already included in the item price.")),
                    .init(text: Text("• Shipping times depend on the delivery provider and your location. You’ll receive full delivery details by email once your order has been dispatched."))
                ],
                bottomSpacing: 20
            ),
            .init(
                title: "Return policy",
                lines: [
                    .init(text: Text("• If you’d like to return an item, we can offer an exchange.")),
                    .init(text: Text("• Please note: Peer Tokens cannot be refunded."))
                ],
                bottomSpacing: 25
            ),
            .init(
                title: "Delivery area",
                lines: [
                    .init(text: Text("Delivery is currently available only within Germany."))
                ],
                bottomSpacing: 25
            ),
            .init(
                title: "Need help?",
                lines: [
                    .init(text: Text("If you have any issues with your order, delivery, or product, feel free to reach out to us:"), bottomSpacing: 10),
                    .init(
                        text: Text("• Email: ") + Text("help.peernetwork@gmail.com").underline().bold(),
                        bottomSpacing: 10
                    ),
                    .init(text: Text("We’re here to help."))
                ],
                bottomSpacing: 0
            )
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            Capsule()
                .frame(height: 1.5)
                .foregroundStyle(Colors.whiteSecondary)
                .padding(.bottom, 13)

            ViewThatFits(in: .vertical) {
                sectionsContent

                ScrollView {
                    sectionsContent
                }
                .scrollIndicators(.hidden)
            }
        }
        .appFont(.bodyRegular)
        .foregroundStyle(Colors.whitePrimary)
        .multilineTextAlignment(.leading)
        .padding(20)
        .background(Colors.inactiveDark)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    private var sectionsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sections) { section in
                Text(section.title)
                    .appFont(.bodyBold)

                ForEach(section.lines) { line in
                    line.text
                        .padding(.bottom, line.bottomSpacing)
                }

                if section.bottomSpacing > 0 {
                    Spacer().frame(height: section.bottomSpacing)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("FAQ’s")
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: dismiss) {
                Icons.x
                    .iconSize(height: 16)
                    .contentShape(.rect)
            }
        }
        .padding(.bottom, 10)
    }
}
