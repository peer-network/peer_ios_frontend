//
//  View+Extensions.swift
//  Environment
//
//  Created by Артем Васин on 08.01.25.
//

import SwiftUI
import Translation

extension View {
    public func addTranslateView(isPresented: Binding<Bool>, text: String) -> some View {
        if #available(iOS 17.4, *) {
            return self.translationPresentation(isPresented: isPresented, text: text)
        } else {
            return self
        }
    }
}
