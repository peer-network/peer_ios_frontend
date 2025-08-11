//
//  UnblockUserXButton.swift
//  DesignSystem
//
//  Created by Artem Vasin on 18.06.25.
//

import SwiftUI
import Environment
import Models

@MainActor
public final class UnblockUserXButtonButtonViewModel: ObservableObject {
    public unowned var apiService: APIService!

    private let id: String

    public init(id: String) {
        self.id = id
    }

    public func toggleBlock() async throws -> Bool {
        do {
            let result = await apiService.toggleHideUserContent(with: id)

            switch result {
            case .success(let isBlocked):
                return isBlocked
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            throw error
        }
    }
}

public struct UnblockUserXButton: View {
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var viewModel: UnblockUserXButtonButtonViewModel

    var onUnblock: (() -> Void)?

    public init(userId: String, onUnblock: (() -> Void)? = nil) {
        _viewModel = .init(wrappedValue: .init(id: userId))
        self.onUnblock = onUnblock
    }

    public var body: some View {
        Button {
            Task {
                do {
                    let isBlocked = try await viewModel.toggleBlock()
                    if isBlocked {
                        showPopup(text: "User's content will be hidden.")
                    } else {
                        showPopup(text: "User's content will be visible.")
                        onUnblock?()
                    }
                } catch {
                    showPopup(
                        text: error.userFriendlyDescription
                    )
                }
            }
        } label: {
            Icons.x
                .iconSize(height: 13)
                .foregroundStyle(Colors.whitePrimary)
                .frame(width: 31, height: 31, alignment: .center)
                .contentShape(.rect)
        }
        .onFirstAppear {
            viewModel.apiService = apiManager.apiService
        }
    }
}
