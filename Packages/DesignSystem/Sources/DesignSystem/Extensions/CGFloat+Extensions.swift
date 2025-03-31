//
//  CGFloat+Extensions.swift
//  DesignSystem
//
//  Created by Артем Васин on 31.12.24.
//

import Foundation

@MainActor
extension CGFloat {
    public static var layoutPadding: CGFloat {
        Theme.shared.compactLayoutPadding ? 20 : 8
    }
    
    public static let postComponentSpacing: CGFloat = 6
    public static let postColumnsSpacing: CGFloat = 8
}
