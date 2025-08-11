//
//  Image+Extensions.swift
//  DesignSystem
//
//  Created by Artem Vasin on 07.03.25.
//

import SwiftUI

public extension Image {
    /// Modifier for Icons. Makes it resizable and aspect ratio = fit
    /// - Parameter size: width and height size
    /// - Returns: Modified View
    func iconSize(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height, alignment: .center)
    }
}
