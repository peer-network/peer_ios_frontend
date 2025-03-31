//
//  MediaUIImageTransferable.swift
//  MediaUI
//
//  Created by Артем Васин on 10.01.25.
//

import SwiftUI

public struct MediaUIImageTransferable: Codable, Transferable {
    public let url: URL
    
    public func fetchData() async -> Data {
        do {
            return try await URLSession.shared.data(from: url).0
        } catch {
            return Data()
        }
    }
    
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { transferable in
            await transferable.fetchData()
        }
    }
}
