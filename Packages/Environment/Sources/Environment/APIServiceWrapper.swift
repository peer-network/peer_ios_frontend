//
//  APIServiceWrapper.swift
//  Environment
//
//  Created by Alexander Savchenko on 04.04.25.
//

import Models
import Combine
import Networking

@MainActor
public final class APIServiceManager: ObservableObject, APIServiceWrapper {
    public let apiService: APIService = APIServiceGraphQL()
    
    public init(){}
}
