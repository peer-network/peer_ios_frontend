//
//  RecipientPickerViewModel2.swift
//  Wallet
//
//  Created by Artem Vasin on 03.12.25.
//

import Combine
import Environment
import Models

@MainActor
final class RecipientPickerViewModel2: ObservableObject {
    @Published private(set) var state: PaginatedContentState<[RowUser]> = .display(content: [], hasMore: .none)

    var currentOffset: Int = 0
    private var fetchTask: Task<Void, Never>?

    init() {}

    func fetchContent(reset: Bool) {
    }
}
