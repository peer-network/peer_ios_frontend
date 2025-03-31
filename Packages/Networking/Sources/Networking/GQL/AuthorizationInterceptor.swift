//
//  AuthorizationInterceptor.swift
//  Networking
//
//  Created by Артем Васин on 18.12.24.
//

import Apollo
import ApolloAPI
import Foundation
import TokenKeychainManager

class AuthorizationInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString

    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation : GraphQLOperation {

        if let token = TokenKeychainManager.shared.getAccessToken() {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")
        }

        chain.proceedAsync(
            request: request,
            response: response,
            interceptor: self,
            completion: completion
        )
    }
}
