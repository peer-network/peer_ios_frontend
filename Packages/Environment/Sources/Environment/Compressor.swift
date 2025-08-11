//
//  Compressor.swift
//  Environment
//
//  Created by Артем Васин on 23.12.24.
//

import SwiftUI

public final class Compressor {
    public static let shared = Compressor()
    
    private init() {}
    
    public enum CompressorError: Error {
        case noData
    }
    
    public func compressImageForUpload(
        _ image: UIImage,
        maxSize: Int = 1 * 1024 * 1024,
        maxHeight: CGFloat = 3000,
        maxWidth: CGFloat = 3000
    ) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .utility).async {
                autoreleasepool {
                    var resizedImage = image
                    if image.size.height > maxHeight || image.size.width > maxWidth {
                        let heightFactor = image.size.height / maxHeight
                        let widthFactor = image.size.width / maxWidth
                        let scaleFactor = max(heightFactor, widthFactor)
                        let newSize = CGSize(
                            width: image.size.width / scaleFactor,
                            height: image.size.height / scaleFactor
                        )
                        resizedImage = self.resize(image: image, to: newSize)
                    }
                    
                    var quality: CGFloat = 0.9
                    guard var data = resizedImage.jpegData(compressionQuality: quality) else {
                        continuation.resume(throwing: CompressorError.noData)
                        return
                    }
                    
                    while data.count > maxSize && quality > 0.1 {
                        quality -= 0.1
                        if let newData = resizedImage.jpegData(compressionQuality: quality) {
                            data = newData
                        }
                    }
                    
                    if data.count > maxSize {
                        continuation.resume(throwing: CompressorError.noData)
                    } else {
                        continuation.resume(returning: data)
                    }
                }
            }
        }
    }
    
    private func resize(image: UIImage, to size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
