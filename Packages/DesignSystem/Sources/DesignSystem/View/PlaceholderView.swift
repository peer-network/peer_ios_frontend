//
//  PlaceholderView.swift
//  DesignSystem
//
//  Created by Артем Васин on 02.01.25.
//

import SwiftUI
import SFSafeSymbols

public struct PlaceholderView: View {
    public let icon: SFSymbol
    public let title: LocalizedStringKey
    public let message: LocalizedStringKey
    
    public init(icon: SFSymbol, title: LocalizedStringKey, message: LocalizedStringKey) {
        self.icon = icon
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView(
                title,
                systemImage: icon.rawValue,
                description: Text(message))
        } else {
            Label(title, systemSymbol: icon)
        }
    }
}

#Preview {
    PlaceholderView(icon: .exclamationmarkTriangleFill, title: "No Content Available", message: "We couldn’t find any content to display here. Please try again later.")
}
