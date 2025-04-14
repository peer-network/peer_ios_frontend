//
//  VersionHistoryServiceProtocol.swift
//  VersionHistory
//
//  Created by Artem Vasin on 11.04.25.
//

public protocol VersionHistoryServiceProtocol {
    func fetchVersionHistory() async throws -> [VersionHistoryItem]
}
