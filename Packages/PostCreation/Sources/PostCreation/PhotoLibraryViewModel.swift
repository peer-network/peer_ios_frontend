//
//  PhotoLibraryViewModel.swift
//  PostCreation
//
//  Created by Артем Васин on 11.02.25.
//

import SwiftUI
import Photos

@MainActor
final class PhotoLibraryViewModel: ObservableObject {
    @Published var photoAssets: [PHAsset] = []
    @Published var longVideoAssets: [PHAsset] = []
    @Published var shortVideoAssets: [PHAsset] = []
    @Published var photoAccessGranted = true

    func requestAuthorizationAndFetch() {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                Task {
                    await self.fetchPhotos()
                }
            } else {
                self.photoAccessGranted = false
            }
        }
    }

    func fetchPhotos() async {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = .max
        let result = PHAsset.fetchAssets(with: .image, options: options)
        var fetchedAssets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            fetchedAssets.append(asset)
        }
        await MainActor.run {
            self.photoAssets = fetchedAssets
        }
    }

    func fetchLongVideos() async {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "duration >= %d AND duration <= %d", 5, 30)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = .max
        let result = PHAsset.fetchAssets(with: .video, options: options)
        var fetchedAssets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            fetchedAssets.append(asset)
        }
        await MainActor.run {
            self.longVideoAssets = fetchedAssets
        }
    }

    func fetchShortVideos() async {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "duration < %d", 30)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = .max
        let result = PHAsset.fetchAssets(with: .video, options: options)
        var fetchedAssets: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            fetchedAssets.append(asset)
        }
        await MainActor.run {
            self.shortVideoAssets = fetchedAssets
        }
    }

    func fetchTextFiles(pathURL: URL) -> [String] {
        var textURLs: [String] = []
        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsSubdirectoryDescendants, .skipsHiddenFiles]

        let enumerator = fileManager.enumerator(at: pathURL, includingPropertiesForKeys: keys, options: options) { url, error in
            return true
        }

        if let enumerator {
            while let file = enumerator.nextObject(), let fileURL = file as? URL {
                let path = URL(fileURLWithPath: fileURL.absoluteString, relativeTo: pathURL).path
                if path.hasSuffix(".txt") {
                    textURLs.append(path)
                }
            }
        }

        return textURLs
    }
}
