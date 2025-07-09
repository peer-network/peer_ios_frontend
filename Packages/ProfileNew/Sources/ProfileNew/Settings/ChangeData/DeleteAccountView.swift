//
//  DeleteAccountView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 07.07.25.
//

import SwiftUI
import DesignSystem
import Analytics
import Environment
import Models

public struct DeleteAccountView: View {
    private let onSubmit: (String) async -> Result<Void, APIError>

    @FocusState private var isCurrentPasswordFocused: Bool

    public init(onSubmit: @escaping (String) async -> Result<Void, APIError>) {
        self.onSubmit = onSubmit
    }

    public var body: some View {
        DataEditView(
            title: "Delete account",
            submitLabel: "Confirm",
            submitAction: { currentPassword in
                await onSubmit(currentPassword)
            },
            content: {
            },
            isPasswordFocused: $isCurrentPasswordFocused
        )
        .onAppear {
            isCurrentPasswordFocused = true
        }
    }
}
