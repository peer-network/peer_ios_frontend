//
//  HiddenBadgeView.swift
//  Post
//
//  Created by Artem Vasin on 17.11.25.
//

import SwiftUI
import DesignSystem

struct HiddenBadgeView: View {
    var body: some View {
        HStack(spacing: 7) {
            IconsNew.eyeWithSlash
                .iconSize(height: 15)

            Text("Hidden")
                .appFont(.smallLabelRegular)
                .lineLimit(1)
        }
        .foregroundStyle(Colors.whiteSecondary)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}

struct HiddenBadgeDarkView: View {
    var body: some View {
        HStack(spacing: 7) {
            IconsNew.eyeWithSlash
                .iconSize(height: 15)

            Text("Hidden")
                .appFont(.smallLabelRegular)
                .lineLimit(1)
        }
        .foregroundStyle(Colors.whiteSecondary)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.textActive)
        }
    }
}
