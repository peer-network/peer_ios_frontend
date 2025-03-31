//
//  ProfileViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 27.02.25.
//

import SwiftUI
import Models
import Networking
import GQLOperationsUser
import Environment

@MainActor
final class ProfileViewModel: ObservableObject {
    enum ProfileState {
        case loading
        case data(user: User)
        case error(error: Error)
    }

    private let userId: String

    @Published private(set) var profileState: ProfileState = .loading
    @Published private(set) var user: User?
    @Published private(set) var fetchedBio = ""

    init(userId: String) {
        self.userId = userId
        Task {
            await fetchUser()
            await fetchBio()
        }
    }

    func fetchUser() async {
        do {
            let result = try await GQLClient.shared.fetch(query: GetProfileQuery(userid: userId), cachePolicy: .fetchIgnoringCacheCompletely)

            guard
                let data = result.profile.affectedRows,
                let fetchedUser = User(gqlUser: data)
            else {
                throw GQLError.missingData
            }

            user = fetchedUser
            
            profileState = .data(user: fetchedUser)
        } catch {
            if let user {
                profileState = .data(user: user)
            } else {
                profileState = .error(error: error)
            }
        }
    }

    func fetchBio() async {
        guard let url = user?.bioURL else { return }

        do {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
            let session = URLSession(configuration: config)
            let (data, _) = try await session.data(from: url)
            guard let text = String(data: data, encoding: .utf8) else { return }
//            try? Task.checkCancellation()
            fetchedBio = text
        } catch is CancellationError {
        } catch {
//            fetchedBio = ""
        }
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
}
