//
//  RoundedShapeModifier.swift
//  PeerApp
//
//  Created by Artem Vasin on 04.11.25.
//

import SwiftUI
import DesignSystem

struct RoundedShapeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Colors.inactiveDark)
            .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}
