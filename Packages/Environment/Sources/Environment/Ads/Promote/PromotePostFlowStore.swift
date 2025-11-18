//
//  PromotePostFlowStore.swift
//  Environment
//
//  Created by Artem Vasin on 03.11.25.
//

import SwiftUI
import Models

@MainActor
public final class PromotePostFlowStore: ObservableObject {
    public static let shared = PromotePostFlowStore()

    @Published private var flows: [UUID: PromotePostCoordinator] = [:]

    public func startFlow(post: Post,
                          apiService: APIService,
                          tokenomics: ConstantsConfig.Tokenomics,
                          popupManager: any SystemPopupManaging,
                          onGoToProfile: @escaping () -> Void,
                          onGoToPost: @escaping () -> Void,
                          onFinish: @escaping () -> Void) -> UUID
    {
        let id = UUID()
        let coordinator = PromotePostCoordinator(
            post: post,
            dependencies: .init(apiService: apiService, tokenomics: tokenomics, popupManager: popupManager),
            onGoToProfile: { [weak self] in
                self?.endFlow(id)
                onGoToProfile()
            },
            onGoToPost: { [weak self] in
                self?.endFlow(id)
                onGoToPost()
            },
            onFinish: { [weak self] in
                self?.endFlow(id)
                onFinish()
            }
        )
        flows[id] = coordinator
        return id
    }

    public func coordinator(for id: UUID) -> PromotePostCoordinator? {
        flows[id]
    }

    public func endFlow(_ id: UUID) {
        flows[id] = nil
    }
}
