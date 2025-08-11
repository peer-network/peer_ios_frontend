//
//  SettingsViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 10.03.25.
//

import SwiftUI
import Environment
import Models

@MainActor
final class SettingsViewModel: ObservableObject {
    public unowned var apiService: APIService!
    
    enum BioUpdatingState {
        case loading
        case success
        case failure
    }

    @Published var bio: String = ""
    @Published var bioState: BioUpdatingState = .loading
    @Published var email: String = ""
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var bioUrl: URL?

    init() {
        if let user = AccountManager.shared.user {
            username = user.username
            bioUrl = user.bioURL
        }
    }

    func updateBio() async throws {
        bioState = .loading
        let base64String = Data(bio.utf8).base64EncodedString()
        let base64TextString = "data:text/plain;base64,\(base64String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "\\\""))"
        
        let result = await apiService.updateBio(new: base64TextString)
        
        switch result {
        case .success:
            bioState = .success
        case .failure(let apiError):
            bioState = .failure
            throw apiError
        }
    }

    func uploadProfileImage(_ image: UIImage) async throws {
        let compressedImageData = try await Compressor.shared.compressImageForUpload(image)

        let base64String = compressedImageData.base64EncodedString()
        let base64ImageString = "data:image/jpeg;base64,\(base64String)"
        
        let result = await apiService.uploadProfileImage(new: base64ImageString)

        switch result {
        case .success:
            break
        case .failure(let apiError):
            throw apiError
        }
    }

    func fetchBio(url: URL?) async {
        guard let url else { return }

        do {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
            let session = URLSession(configuration: config)
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.missingData
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.missingData
            }

            guard let text = String(data: data, encoding: .utf8) else {
                throw APIError.missingData
            }
            withAnimation {
                bio = text
            }
            bioState = .success
        } catch {
            bio = ""
            bioState = .failure
        }
    }
}
