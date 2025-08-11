//
//  TagsView.swift
//  PeerApp
//
//  Created by Artem Vasin on 11.03.25.
//

import SwiftUI

struct TagsView<Content: View, Tag: Equatable>: View where Tag: Hashable {
    let spacing: CGFloat = 10
    let animation: Animation = .easeInOut(duration: 0.2)
    let tags: [Tag]
    @ViewBuilder let content: (Tag) -> Content
    let onClick: (Tag) -> ()

    var body: some View {
        CustomChipLayout(spacing: spacing) {
            ForEach(tags, id: \.self) { tag in
                content(tag)
                    .contentShape(.rect)
                    .onTapGesture {
                        onClick(tag)
                    }
            }
        }
    }
}

fileprivate struct CustomChipLayout: Layout {
    var spacing: CGFloat
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        return .init(width: width, height: maxHeight(proposal: proposal, subviews: subviews))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin

        for subview in subviews {
            let fitSize = subview.sizeThatFits(proposal)

            if (origin.x + fitSize.width) > bounds.maxX {
                origin.x = bounds.minX
                origin.y += fitSize.height + spacing

                subview.place(at: origin, proposal: proposal)
                origin.x += fitSize.width + spacing
            } else {
                subview.place(at: origin, proposal: proposal)
                origin.x += fitSize.width + spacing
            }
        }
    }

    private func maxHeight(proposal: ProposedViewSize, subviews: Subviews) -> CGFloat {
        var origin: CGPoint = .zero

        for subview in subviews {
            let fitSize = subview.sizeThatFits(proposal)

            if (origin.x + fitSize.width) > (proposal.width ?? 0) {
                origin.x = 0
                origin.y += fitSize.height + spacing

                origin.x += fitSize.width + spacing
            } else {
                origin.x += fitSize.width + spacing
            }

            if subview == subviews.last {
                origin.y += fitSize.height
            }
        }

        return origin.y
    }
}
