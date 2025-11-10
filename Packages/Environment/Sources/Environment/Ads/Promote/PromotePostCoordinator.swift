//
//  PromotePostCoordinator.swift
//  Environment
//
//  Created by Artem Vasin on 03.11.25.
//

import SwiftUI
import Models

@MainActor
public final class PromotePostCoordinator: ObservableObject {
    public struct Dependencies {
        let apiService: APIService
        let tokenomics: ConstantsConfig.Tokenomics
        let popupManager: any SystemPopupManaging
    }

    private let deps: Dependencies
    private let onGoToProfile: () -> Void
    private let onGoToPost: () -> Void
    private let onFinish: () -> Void
    private let post: Post

    public let viewModel: AdViewModel

    public init(post: Post, dependencies: Dependencies, onGoToProfile: @escaping () -> Void, onGoToPost: @escaping () -> Void, onFinish: @escaping () -> Void) {
        self.post = post
        self.deps = dependencies
        self.onGoToProfile = onGoToProfile
        self.onGoToPost = onGoToPost
        self.onFinish = onFinish

        let vm = AdViewModel(post: post, tokenomics: dependencies.tokenomics, onGoToProfile: onGoToProfile, onGoToPost: onGoToPost)
        vm.apiService = dependencies.apiService
        vm.popupService = dependencies.popupManager
        self.viewModel = vm
    }

    public func pay() async {
        await viewModel.startPromotion()
    }

    public func finish() {
        onFinish()
    }

    public func cancel() {
        onFinish()
    }
}
