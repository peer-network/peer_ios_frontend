//
//  DataEditView.swift
//  ProfileNew
//
//  Created by Artem Vasin on 13.05.25.
//

import SwiftUI
import DesignSystem
import Analytics
import Environment
import Models

struct DataEditView<Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let submitLabel: String
    let submitAction: (String) async -> Result<Void, APIError>
    @ViewBuilder let content: () -> Content
    @FocusState.Binding var isPasswordFocused: Bool

    @State private var currentPassword: String = ""
    @State private var validationError: String?

    @State private var showPassword: Bool = false

    var body: some View {
        HeaderContainer(actionsToDisplay: .commentsAndLikes) {
            Text("Settings")
        } content: {
            ScrollView {
                VStack(spacing: 15) {
                    pageTitle
                        .frame(maxWidth: .infinity, alignment: .leading)

                    content()

                    passwordConfirmationTextField

                    if let validationError {
                        errorView(text: validationError)
                    }

                    submitButton
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }

    }

    private var pageTitle: some View {
        Text(title)
            .font(.customFont(weight: .regular, size: .title))
            .foregroundStyle(Colors.whitePrimary)
            .multilineTextAlignment(.leading)
    }

    private var submitButton: some View {
        Button {
            Task {
                withAnimation {
                    validationError = nil
                }
                guard validateInputs() else { return }

                let result = await submitAction(currentPassword)

                switch result {
                    case .success:
                        await MainActor.run {
                            showPopup(
                                text: "Successfully updated!"
                            )
                            dismiss()
                        }
                    case .failure(let error):
                        await MainActor.run {
                            withAnimation {
                                validationError = error.userFriendlyDescription
                            }
                        }
                }
            }
        } label: {
            Text(submitLabel)
        }
        .buttonStyle(TargetButtonStyle())
    }

    private var passwordConfirmationTextField: some View {
        FormTextField(
            placeholder: "Current password",
            text: $currentPassword,
            type: showPassword ? .default : .secured,
            icon: currentPassword.isEmpty ? nil : (showPassword ? Icons.eyeSlash : Icons.eye)
        ) {
            showPassword.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPasswordFocused = true
            }
        }
        .focused($isPasswordFocused)
        .submitLabel(.done)
        .textContentType(.password)
        .keyboardType(.asciiCapable)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onTapGesture {
            isPasswordFocused = true
        }
    }

    private func errorView(text: String) -> some View {
        Text(text)
            .font(.customFont(weight: .regular, size: .footnote))
            .multilineTextAlignment(.center)
            .foregroundStyle(Colors.warning)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func validateInputs() -> Bool {
        guard !currentPassword.isEmpty else {
            withAnimation {
                validationError = "Please enter your current password."
            }
            return false
        }

        return true
    }
}

#Preview {
    DataEditView(
        title: "Change username",
        submitLabel: "Save",
        submitAction: { _ in
            return .success(())
        },
        content: {
            Text("123")
        },
        isPasswordFocused: FocusState<Bool>().projectedValue
    )
    .analyticsService(MockAnalyticsService())
    .environmentObject(Router())
    .environmentObject(AccountManager.shared)
}
