//
//  VideoFileTransferable.swift
//  PostCreation
//
//  Created by Artem Vasin on 28.05.25.
//

import CoreTransferable

struct VideoFileTransferable: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { file in
            // Preserve original file extension or default to mp4
            let originalExtension = file.url.pathExtension
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(originalExtension.isEmpty ? "mp4" : originalExtension)

            try FileManager.default.copyItem(at: file.url, to: tempURL)
            return SentTransferredFile(tempURL)
        } importing: { received in
            let originalExtension = received.file.pathExtension
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(originalExtension.isEmpty ? "mp4" : originalExtension)

            try FileManager.default.copyItem(at: received.file, to: tempURL)
            return Self(url: tempURL)
        }
    }
}
