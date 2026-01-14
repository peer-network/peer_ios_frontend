//
//  ShopTab.swift
//  PeerApp
//
//  Created by Artem Vasin on 07.03.25.
//

import SwiftUI
import Environment

struct ShopTab: View {
    @Environment(\.selectedTabEmptyPath) private var selectedTabEmptyPath

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var apiManager: APIServiceManager

    @StateObject private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            ShopProfileView(shopUserId: Env.shopUserId)
                .toolbar(.hidden, for: .navigationBar)
                .withAppRouter(appState: appState, apiServiceManager: apiManager, router: router)
                .navigationDestination(for: ShopRoute.self, destination: { route in
                    switch route {
                        case .purchase(let item):
                            ShopItemPurchaseView(item: item)
                                .toolbar(.hidden, for: .navigationBar)
                        case .checkout(let flowID):
                            if let flow = router.object(id: flowID) as? ShopPurchaseFlow {
                                ShopItemCheckoutView()
                                    .environmentObject(flow)
                                    .toolbar(.hidden, for: .navigationBar)
                            } else {
                                Text("Purchase session expired")
                            }
                    }
                })
                .withSheetDestinations(sheetDestinations: $router.presentedSheet, apiServiceManager: apiManager)
                .onChange(of: selectedTabEmptyPath) {
                    if selectedTabEmptyPath == 3, !router.path.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            router.emptyPath()
                        }
                    }
                }
        }
        .withSafariRouter()
        .environmentObject(router)
    }
}
