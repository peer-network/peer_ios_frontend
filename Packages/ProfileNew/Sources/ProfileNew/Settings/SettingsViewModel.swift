//
//  SettingsViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 10.03.25.
//

import SwiftUI
import Environment
import Networking
import GQLOperationsUser

@MainActor
final class SettingsViewModel: ObservableObject {
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

    init() {
        if let user = AccountManager.shared.user {
            username = user.username
            Task {
                await fetchBio(url: user.bioURL)
            }
        }
    }

    func updateBio() async throws {
        bioState = .loading
        let base64String = Data(bio.utf8).base64EncodedString()
        let base64TextString = "data:text/plain;base64,\(base64String.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "\\\""))"
        let result = try await GQLClient.shared.mutate(mutation: UpdateBioMutation(biography: base64TextString))

        guard result.updateBiography.status == "success" else {
            bioState = .failure
            throw GQLError.missingData
        }

        bioState = .success
    }

    func uploadProfileImage(_ image: UIImage) async throws {
        let compressedImageData = try await Compressor.shared.compressImageForUpload(image)

        let base64String = compressedImageData.base64EncodedString()
        let base64ImageString = "data:image/jpeg;base64,\(base64String)"

        let result = try await GQLClient.shared.mutate(mutation: UpdateAvatarMutation(img: base64ImageString))

        guard result.updateProfilePicture.status == "success" else {
            throw GQLError.missingData
        }
    }

    private func fetchBio(url: URL?) async {
        guard let url else { return }

        do {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
            let session = URLSession(configuration: config)
            let (data, _) = try await session.data(from: url)
            guard let text = String(data: data, encoding: .utf8) else { return }
            bio = text
            bioState = .success
        } catch {
//            bio = ""
            bioState = .failure
        }
    }
}
