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
        IconsNew.flag
            .iconSize(height: 24)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundStyle(Colors.redAccent)
    }
}
