//
//  ShopPurchaseFlow.swift
//  PeerApp
//
//  Created by Artem Vasin on 12.01.26.
//

import Combine
import SwiftUI
import Models

@MainActor
final class ShopPurchaseFlow: ObservableObject {
    let id: UUID
    let viewModel: ShopItemPurchaseViewModel

    private var cancellables = Set<AnyCancellable>()

    init(id: UUID = UUID(), item: ShopListing) {
        self.id = id
        self.viewModel = ShopItemPurchaseViewModel(item: item)

        viewModel.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    func binding<T>(_ keyPath: ReferenceWritableKeyPath<ShopItemPurchaseViewModel, T>) -> Binding<T> {
        Binding(
            get: { self.viewModel[keyPath: keyPath] },
            set: { self.viewModel[keyPath: keyPath] = $0 }
        )
    }
}
