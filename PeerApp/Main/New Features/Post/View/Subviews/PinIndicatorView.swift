//
//  PinIndicatorView.swift
//  PeerApp
//
//  Created by Artem Vasin on 02.02.26.
//

import SwiftUI
import DesignSystem

struct PinIndicatorView2: View {
    var body: some View {
        Icons.pin
            .iconSize(height: 15.61)
            .foregroundStyle(Colors.whitePrimary)
            .frame(width: 37, height: 37)
            .background {
                Circle()
                    .foregroundStyle(Colors.version)
            }
    }
}
