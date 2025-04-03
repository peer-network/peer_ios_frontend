//
//  APIService.swift
//  Models
//
//  Created by Alexander Savchenko on 01.04.25.
//

public enum APIError: Error {
    case serverError(error: Error)
    case missingData
}

public protocol APIService {
    func fetchAuthorizedUserID() async -> Result<String, APIError>
}
