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
        maxSize: Int = 5 * 1024 * 1024,
        maxHeight: Double = 5000,
        maxWidth: Double = 5000
    ) async throws -> Data {
        var image = image
        
        if image.size.height > maxHeight || image.size.width > maxWidth {
            let heightFactor = image.size.height / maxHeight
            let widthFactor = image.size.width / maxWidth
            let maxFactor = max(heightFactor, widthFactor)
            
            image = resize(
                image: image,
                to: .init(
                    width: image.size.width / maxFactor,
                    height: image.size.height / maxFactor
                )
            )
        }
        
        guard var imageData = image.jpegData(compressionQuality: 0.8) else {
            throw CompressorError.noData
        }
        
        var compressionQualityFactor: CGFloat = 0.8
        if imageData.count > maxSize {
            while imageData.count > maxSize && compressionQualityFactor >= 0 {
                guard let compressedImage = UIImage(data: imageData),
                      let compressedData = compressedImage.jpegData(
                        compressionQuality: compressionQualityFactor)
                else {
                    throw CompressorError.noData
                }
                
                imageData = compressedData
                compressionQualityFactor -= 0.1
            }
        }
        
        if imageData.count > maxSize && compressionQualityFactor <= 0 {
            print(imageData)
            throw CompressorError.noData
        }
        
        return imageData
    }
    
    private func resize(image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
