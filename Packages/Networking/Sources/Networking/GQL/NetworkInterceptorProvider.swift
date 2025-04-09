//
//  NetworkInterceptorProvider.swift
//  Networking
//
//  Created by Артем Васин on 18.12.24.
//

import Apollo
import ApolloAPI
import Foundation

class NetworkInterceptorProvider: DefaultInterceptorProvider {
    override func interceptors<Operation>(for operation: Operation) -> [ApolloInterceptor] where Operation : GraphQLOperation {
        var interceptors = super.interceptors(for: operation)
        interceptors.insert(AuthorizationInterceptor(), at: 0)
        return interceptors
    }
}
