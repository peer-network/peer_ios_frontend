//
//  PromotePostStepView.swift
//  PeerApp
//
//  Created by Artem Vasin on 03.11.25.
//

import SwiftUI
import Environment

struct PromotePostStepView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var flows: PromotePostFlowStore

    let flowID: UUID
    let step: PromotePostStep

    var body: some View {
        guard let coordinator = flows.coordinator(for: flowID) else {
            // Flow no longer exists; cleanly pop this route.
            return AnyView(EmptyView())
        }

        switch step {
        case .config:
            return AnyView(
                PinConfigurationView(
                    viewModel: coordinator.viewModel,
                    onBack: { // leave the flow entirely
                        flows.endFlow(flowID)
                        router.path.removeLast()
                    },
                    onNext: {
                        router.path.append(RouterDestination.promotePost(flowID: flowID, step: .checkout))
                    }
                )
            )

        case .checkout:
            return AnyView(
                AdCheckoutView(
                    viewModel: coordinator.viewModel,
                    onBack: { router.path.removeLast() }, // go back to config within the same flow
                    onPay: {
                        await coordinator.pay()
                        coordinator.finish()
                        // Pop checkout
                        router.path.removeLast()
                        // Pop config (flow root) if you want to leave entirely
//                        if let last = router.path.last, case .promotePost(let lastID, .config) = last, lastID == flowID {
                            router.path.removeLast()
//                        }
                        flows.endFlow(flowID)
                    }
                )
            )
        }
    }
}
