//
//  APIServiceWrapper.swift
//  Environment
//
//  Created by Alexander Savchenko on 04.04.25.
//

import Models
import Combine
import Networking

public enum EnvironmentType {
    case normal
    case mock
}

@MainActor
public final class APIServiceManager: ObservableObject, APIServiceWrapper {
    public let apiService: APIService
    
    public init(_ env: EnvironmentType = .normal) {
        switch env {
        case .normal:
            apiService = APIServiceGraphQL()
        case .mock:
            apiService = APIServiceStub()
        }
    }
}
