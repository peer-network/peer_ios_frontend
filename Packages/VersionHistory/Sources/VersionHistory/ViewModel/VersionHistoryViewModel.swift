//
//  VersionHistoryViewModel.swift
//  VersionHistory
//
//  Created by Artem Vasin on 11.04.25.
//

import Combine

@MainActor
public final class VersionHistoryViewModel: ObservableObject {
    @frozen
    public enum VersionHistoryState {
        case idle
        case loading
        case loaded([VersionHistoryItem])
        case error(VersionHistoryError)
    }

    @Published public private(set) var state: VersionHistoryState = .idle

    private let service: VersionHistoryServiceProtocol

    public init(service: VersionHistoryServiceProtocol) {
        self.service = service
    }

    func loadVersionHistory() async {
        state = .loading

        do {
            let history = try await service.fetchVersionHistory()
            state = .loaded(history)
        } catch let error as VersionHistoryError {
            state = .error(error)
        } catch {
            state = .error(.unknown)
        }
    }
}
