//
//  EditUsernameView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 13.05.25.
//

import SwiftUI
import DesignSystem
import Analytics
import Environment
import Models

public struct EditUsernameView: View {
    private let onSubmit: (String, String) async -> Result<Void, APIError>

    @State private var newUsername: String = ""

    @FocusState private var isUsernameFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    public init(onSubmit: @escaping (String, String) async -> Result<Void, APIError>) {
        self.onSubmit = onSubmit
    }

    public var body: some View {
        DataEditView(
            title: "Change username",
            submitLabel: "Save",
            submitAction: { password in
                await onSubmit(newUsername, password)
            },
            content: {
                usernameTextField
            },
            isPasswordFocused: $isPasswordFocused
        )
        .onAppear {
            isUsernameFocused = true
        }
        .onChange(of: newUsername) {
            if newUsername.count > 23 {
                newUsername = String(newUsername.prefix(23))
            }
        }
    }

    private var usernameTextField: some View {
        ValidatedTextField(
            placeholder: "New username",
            text: $newUsername,
            type: .default,
            icon: isValidUsername(newUsername) ? Icons.checkmarkCircle : Icons.xCircle,
            hint: "3-23 characters, letters/numbers/_ only",
            errorMessage: "Invalid username format.",
            isValid: isValidUsername(newUsername),
            focused: $isUsernameFocused
        )
        .submitLabel(.next)
        .onSubmit {
            isPasswordFocused = true
        }
        .textContentType(.username)
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            isUsernameFocused = true
        }
    }

    private func isValidUsername(_ username: String) -> Bool {
        let pattern = #"^[A-Za-z0-9_]{3,23}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: username)
    }

    private struct ValidatedTextField: View {
        let placeholder: String
        @Binding var text: String
        let type: FormTextField.TextFieldType
        var icon: Image? = nil
        var onIconClick: (() -> Void)? = nil
        var hint: String? = nil
        let errorMessage: String
        let isValid: Bool
        @FocusState.Binding var focused: Bool

        /// This property decides which text (if any) will be displayed below the TextField.
        private var helperText: String? {
            if focused {
                // If focused, show the hint
                if let hint {
                    return hint
                } else {
                    return nil
                }
            } else if !text.isEmpty, !isValid {
                // If not empty but invalid, show error
                return errorMessage
            } else {
                // Else no extra text
                return nil
            }
        }

        /// If the displayed text is the error message, style it with .warning
        private var isError: Bool {
            helperText == errorMessage
        }

        var body: some View {
            VStack(alignment: .center, spacing: 15) {
                FormTextField(
                    placeholder: placeholder,
                    text: $text,
                    type: type,
                    icon: (!focused && !text.isEmpty) ? icon : nil,
                    onIconClick: onIconClick
                )
                .focused($focused)

                if let helperText {
                    Text(helperText)
                        .font(.customFont(weight: .regular, size: .footnote))
                        .foregroundStyle(isError ? Colors.warning : Colors.whitePrimary.opacity(0.6))
                }
            }
        }
    }
}

#Preview {
    EditUsernameView(onSubmit: {_, _ in return .success(()) })
        .analyticsService(MockAnalyticsService())
        .environmentObject(Router())
        .environmentObject(AccountManager.shared)
}
