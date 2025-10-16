//
//  PinIndicatorView.swift
//  PeerApp
//
//  Created by Artem Vasin on 10.09.25.
//

import SwiftUI
import DesignSystem

struct PinIndicatorView: View {
    var body: some View {
        Icons.pin
            .iconSize(height: 15)
            .foregroundStyle(Colors.whitePrimary)
            .padding(7.5)
            .background {
                Circle()
                    .foregroundStyle(Colors.version)
            }
    }
}
