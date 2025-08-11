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
import GQLOperationsGuest

class AuthorizationInterceptor: ApolloInterceptor {
    public var id: String = UUID().uuidString

    func interceptAsync<Operation>(
        chain: RequestChain,
        request: HTTPRequest<Operation>,
        response: HTTPResponse<Operation>?,
        completion: @escaping (Result<GraphQLResult<Operation.Data>, Error>) -> Void
    ) where Operation : GraphQLOperation {
        
        // If there is no access token then proceed without it
        guard let token = TokenKeychainManager.shared.getAccessToken() else {
            chain.proceedAsync(
                request: request,
                response: response,
                interceptor: self,
                completion: completion
            )
            return
        }

        // If access token is not expired then proceed with it
        if !TokenKeychainManager.shared.isAccessTokenExpired {
            request.addHeader(name: "Authorization", value: "Bearer \(token)")

            chain.proceedAsync(
                request: request,
                response: response,
                interceptor: self,
                completion: completion
            )
            return
        }

        // Token expired — try refreshing it
        guard
            let refreshToken = TokenKeychainManager.shared.getRefreshToken(),
            !TokenKeychainManager.shared.isRefreshTokenExpired
        else {
            // No valid refresh token, proceed without it
            TokenKeychainManager.shared.removeCredentials()
            chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)
            return
        }

        TokenKeychainManager.shared.removeCredentials()

        // Refresh the token
        Task { [weak self] in
            guard let self = self else { return }

            do {
                let result = try await GQLClient.shared.mutate(
                    mutation: RefreshTokenMutation(refreshToken: refreshToken)
                )

                guard
                    let newAccessToken = result.refreshToken.accessToken,
                    let newRefreshToken = result.refreshToken.refreshToken
                else {
                    // Refresh mutation succeeded but tokens are missing — error
                    throw GQLError.missingData
                }

                // Save new tokens
                TokenKeychainManager.shared.setCredentials(
                    accessToken: newAccessToken,
                    refreshToken: newRefreshToken
                )

                // Attach new access token to the request
                request.addHeader(name: "Authorization", value: "Bearer \(newAccessToken)")

                // Resume the chain
                chain.proceedAsync(request: request, response: response, interceptor: self, completion: completion)

            } catch {
                // Proceed unauthenticated
                chain.handleErrorAsync(error, request: request, response: response, completion: completion)
            }
        }
    }
}
