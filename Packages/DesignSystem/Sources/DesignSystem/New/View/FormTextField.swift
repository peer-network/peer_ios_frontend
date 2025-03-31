//
//  FormTextField.swift
//  DesignSystem
//
//  Created by Артем Васин on 27.01.25.
//

import SwiftUI

public struct FormTextField: View {
    @frozen
    public enum TextFieldType {
        case `default`
        case multiLine
        case secured
    }
    
    private let placeholder: String
    private let text: Binding<String>
    private let type: TextFieldType
    private let icon: Image?
    private let onIconClick: (() -> Void)?
    
    public init(placeholder: String, text: Binding<String>, type: TextFieldType, icon: Image? = nil, onIconClick: (() -> Void)? = nil) {
        self.placeholder = placeholder
        self.text = text
        self.type = type
        self.icon = icon
        self.onIconClick = onIconClick
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 24)
                .foregroundStyle(Color.white)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            
            HStack(alignment: .center, spacing: 10) {
                Group {
                    switch type {
                        case .default:
                            defaultTextField
                        case .multiLine:
                            multiLineTextField
                        case .secured:
                            securedTextField
                    }
                }
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                
                if let icon {
                    Button {
                        onIconClick?()
                    } label: {
                        icon
                            .frame(height: 26)
                            .foregroundStyle(Color.icons)
                            .clipShape(Rectangle())
                    }
                    .disabled(onIconClick == nil)
                }
            }
            .padding(.horizontal, 18)
        }
        .font(.customFont(weight: .regular, size: .body))
        .contentShape(Rectangle())
    }
    
    private var securedTextField: some View {
        SecureField(text: text) {
            placeholderText
        }
    }
    
    private var defaultTextField: some View {
        TextField(text: text, axis: .horizontal) {
            placeholderText
        }
    }
    
    private var multiLineTextField: some View {
        TextField(text: text, axis: .vertical) {
            placeholderText
        }
    }
    
    private var placeholderText: some View {
        Text(placeholder)
            .foregroundStyle(Color.black.opacity(0.5))
    }
}
