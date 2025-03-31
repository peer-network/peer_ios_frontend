//
//  PostActionButtonStyle.swift
//  FeedNew
//
//  Created by Артем Васин on 03.02.25.
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
//            .scaleEffect(configuration.isPressed && !isOn ? 0.8 : 1.0) // don't even toggle pressing animation..?
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
    }
}
