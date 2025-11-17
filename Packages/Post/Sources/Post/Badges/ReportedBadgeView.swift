//
//  ReportedBadgeView.swift
//  Post
//
//  Created by Artem Vasin on 17.11.25.
//

import SwiftUI
import DesignSystem

struct ReportedBadgeView: View {
    var body: some View {
        HStack(spacing: 7) {
            IconsNew.flag
                .iconSize(height: 15)

            Text("Reported")
                .appFont(.smallLabelRegular)
                .lineLimit(1)
        }
        .foregroundStyle(Colors.redAccent)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Colors.inactiveDark)
        }
    }
}
