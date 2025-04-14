//
//  LocalVersionHistoryService.swift
//  VersionHistory
//
//  Created by Artem Vasin on 11.04.25.
//

import Foundation

public class LocalVersionHistoryService: VersionHistoryServiceProtocol {
    private let fileName: String
    private let bundle: Bundle

    public init(fileName: String = "version_history", bundle: Bundle = .main) {
        self.fileName = fileName
        self.bundle = bundle
    }

    public func fetchVersionHistory() async throws -> [VersionHistoryItem] {
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            throw VersionHistoryError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        do {
            return try decoder.decode([VersionHistoryItem].self, from: data)
        } catch {
            throw VersionHistoryError.decodingError
        }
    }
}
