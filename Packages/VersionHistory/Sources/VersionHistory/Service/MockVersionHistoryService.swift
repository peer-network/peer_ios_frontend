//
//  MockVersionHistoryService.swift
//  VersionHistory
//
//  Created by Artem Vasin on 11.04.25.
//

public class MockVersionHistoryService: VersionHistoryServiceProtocol {
    public init() {}

    public func fetchVersionHistory() async throws -> [VersionHistoryItem] {
        // Simulate network delay
        try await Task.sleep(for: .seconds(2))

        return [
            VersionHistoryItem(
                version: "5.0.0",
                date: "5 Feb 2024",
                releaseNotes: [
                    "Views are being counted",
                    "Audio feed is released",
                    "Short videos are fixed",
                    "Sent comments are displayed immediately",
                    "Amount of friends is displayed"
                ]
            ),
            VersionHistoryItem(
                version: "4.9.0",
                date: "5 Feb 2024",
                releaseNotes: [
                    "Dark mode support added",
                    "Performance improvements",
                    "Bug fixes"
                ]
            )
        ]
    }
}
