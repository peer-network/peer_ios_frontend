//
//  EditEmailView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 13.05.25.
//

import SwiftUI
import DesignSystem
import Analytics
import Environment
import Models

public struct EditEmailView: View {
    private let onSubmit: (String, String) async -> Result<Void, APIError>

    @State private var newEmail: String = ""

    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool

    public init(onSubmit: @escaping (String, String) async -> Result<Void, APIError>) {
        self.onSubmit = onSubmit
    }

    public var body: some View {
        DataEditView(
            title: "Change e-mail",
            submitLabel: "Submit",
            submitAction: { password in
                await onSubmit(newEmail, password)
            },
            content: {
                emailTextField
            },
            isPasswordFocused: $isPasswordFocused
        )
        .onAppear {
            isEmailFocused = true
        }
        .onChange(of: newEmail) {
            if newEmail.count > 60 {
                newEmail = String(newEmail.prefix(60))
            }
        }
    }

    private var emailTextField: some View {
        ValidatedTextField(
            placeholder: "New e-mail",
            text: $newEmail,
            type: .default,
            icon: isValidEmail(newEmail) ? Icons.checkmarkCircle : Icons.xCircle,
            errorMessage: "Invalid email format.",
            isValid: isValidEmail(newEmail),
            focused: $isEmailFocused
        )
        .submitLabel(.next)
        .onSubmit {
            isPasswordFocused = true
        }
        .textContentType(.emailAddress)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            isEmailFocused = true
        }
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
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
    EditEmailView(onSubmit: {_, _ in return .success(()) })
        .analyticsService(MockAnalyticsService())
        .environmentObject(Router())
        .environmentObject(AccountManager.shared)
}
