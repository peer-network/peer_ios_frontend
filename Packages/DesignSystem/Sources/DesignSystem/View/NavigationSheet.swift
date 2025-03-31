//
//  NavigationSheet.swift
//  DesignSystem
//
//  Created by Артем Васин on 02.01.25.
//

import SwiftUI

public struct NavigationSheet<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    
    private var content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        NavigationStack {
            content()
                .toolbar {
                    CloseToolbarItem()
                }
        }
    }
}
