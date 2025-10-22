//
//  FloatingNavigationButtons.swift
//  PostCreation
//
//  Created by Artem Vasin on 16.05.25.
//

import SwiftUI
import DesignSystem

struct FloatingNavigationButtons: View {
    let clearAction: () -> Void
    let postAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            let clearButtonConfig = StateButtonConfig(buttonSize: .large, buttonType: .teritary, title: "Clear")

            StateButton(config: clearButtonConfig, action: clearAction)

            let postButtonConfig = StateButtonConfig(buttonSize: .large, buttonType: .primary, title: "Post")

            StateButton(config: postButtonConfig, action: postAction)
        }
    }
}
