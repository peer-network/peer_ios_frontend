//
//  PostActionButtonStyle.swift
//  Post
//
//  Created by Artem Vasin on 19.05.25.
//

import SwiftUI

struct PostActionButtonStyle: ButtonStyle {
    var isOn: Bool
    var tintColor: Color?
    var defaultColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isOn ? tintColor : defaultColor)
            .animation(nil, value: isOn)
            .animation(configuration.isPressed ? nil : .default, value: isOn)
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
}
