//
//  APIServiceManager.swift
//  Environment
//
//  Created by Alexander Savchenko on 04.04.25.
//

import Models
import Combine
import Networking
import Foundation

public enum EnvironmentType {
    case normal(config: APIConfiguration = APIConfiguration())
    case mock
}

public struct APIConfiguration: GQLClientConfigurable {
    public enum Endpoint: String {
        case production = "https://peernetwork.eu/graphql"
        case staging = "https://getpeer.eu/graphql"
        case custom

        public var url: URL {
            switch self {
                case .production, .staging:
                    return URL(string: rawValue)!
                case .custom:
                    if let urlString = UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "customAPIEndpoint"),
                       let url = URL(string: urlString) {
                        return url
                    }
                    return URL(string: "https://getpeer.eu/graphql")! // Fallback
            }
        }
    }

    public let endpoint: Endpoint
    public var apiEndpointURL: URL { endpoint.url }

    public init(endpoint: Endpoint = .production) {
        self.endpoint = endpoint
    }

    public static func setCustomEndpoint(_ urlString: String) {
        UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.set(urlString, forKey: "customAPIEndpoint")
    }

    public static func getCustomEndpoint() -> String? {
        return UserDefaults(suiteName: "group.eu.peernetwork.PeerApp")?.string(forKey: "customAPIEndpoint")
    }
}

@MainActor
public final class APIServiceManager: ObservableObject, APIServiceWrapper {
    public let apiService: APIService

    public init(_ env: EnvironmentType = .normal()) {
        switch env {
            case .normal(let config):
                GQLClient.configure(with: config)
                apiService = APIServiceGraphQL()
            case .mock:
                apiService = APIServiceStub()
        }
    }
}
