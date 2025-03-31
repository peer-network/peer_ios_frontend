//
//  CloseToolbarItem.swift
//  DesignSystem
//
//  Created by Артем Васин on 02.01.25.
//

import SwiftUI
import SFSafeSymbols

public struct CloseToolbarItem: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(
                action: {
                    dismiss()
                },
                label: {
                    Image(systemSymbol: .xmarkCircle)
                }
            )
            .keyboardShortcut(.cancelAction)
        }
    }
}
