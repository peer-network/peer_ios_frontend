//
//  ProfileViewModel.swift
//  ProfileNew
//
//  Created by Artem Vasin on 27.02.25.
//

import SwiftUI
import Models
import Environment

@MainActor
final class ProfileViewModel: ObservableObject {
    enum ProfileState {
        case loading
        case data(user: User)
        case error(error: Error)
    }

    public unowned var apiService: APIService!
    
    public let userId: String

    @Published private(set) var profileState: ProfileState = .loading
    @Published private(set) var user: User?
    @Published private(set) var fetchedBio = ""

    init(userId: String) {
        self.userId = userId
    }

    func fetchUser() async {
        do {
            let result = await apiService.fetchUser(with: userId)
            
            switch result {
            case .success(let fetchedUser):
                user = fetchedUser
                profileState = .data(user: fetchedUser)
            case .failure(let apiError):
                throw apiError
            }
        } catch {
            profileState = .error(error: error)
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
        
        let result = await apiService.uploadProfileImage(new: base64ImageString)
        
        switch result {
        case .success:
            break
        case .failure(let apiError):
            throw apiError
        }
    }
}
