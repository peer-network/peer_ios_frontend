//
//  GQLClient.swift
//  Networking
//
//  Created by Артем Васин on 13.12.24.
//

import Apollo
import ApolloAPI
import ApolloWebSocket
import Foundation

public enum GQLError: Error {
    case serverError(error: Error)
    case missingData
}

public class GQLClient {
    static public let shared = GQLClient()
    
    public let apolloClient: ApolloClient

    private init() {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let provider = NetworkInterceptorProvider(store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: Constants.apiURL)
        
        let webSocket = WebSocket(url: Constants.apiURL, protocol: .graphql_ws)
        let webSocketTransport = WebSocketTransport(websocket: webSocket)
        
        let splitTransport = SplitNetworkTransport(uploadingNetworkTransport: transport, webSocketNetworkTransport: webSocketTransport)
        
        apolloClient = ApolloClient(networkTransport: splitTransport, store: store)
    }
    
    public func fetch<Query>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch) async throws -> Query.Data where Query: GraphQLQuery {
        try await withCheckedThrowingContinuation { continuation in
            var queryAlreadyCompletedOnce = false
            apolloClient.fetch(query: query, cachePolicy: cachePolicy) { result in
                guard !queryAlreadyCompletedOnce else { return }
                queryAlreadyCompletedOnce = true
                switch result {
                    case let .failure(error):
                        continuation.resume(throwing: GQLError.serverError(error: error))
                    case let .success(successResult):
                        guard let data = successResult.data else {
                            continuation.resume(throwing: GQLError.missingData)
                            return
                        }
                        continuation.resume(returning: data)
                }
            }
        }
    }
    
    public func mutate<Mutation>(mutation: Mutation) async throws -> Mutation.Data where Mutation: GraphQLMutation {
        try await withCheckedThrowingContinuation { continuation in
            apolloClient.perform(mutation: mutation) { result in
                switch result {
                    case let .failure(error):
                        continuation.resume(throwing: GQLError.serverError(error: error))
                    case let .success(successResult):
                        guard let data = successResult.data else {
                            continuation.resume(throwing: GQLError.missingData)
                            return
                        }
                        continuation.resume(returning: data)
                }
            }
        }
    }
    
    public func subscribe<Subscription>(subscription: Subscription) -> AsyncThrowingStream<Subscription.Data, Error> where Subscription: GraphQLSubscription {
        AsyncThrowingStream { continuation in
            let cancellable = apolloClient.subscribe(subscription: subscription) { result in
                switch result {
                    case let .failure(error):
                        continuation.finish(throwing: GQLError.serverError(error: error))
                    case let .success(successResult):
                        guard let data = successResult.data else {
                            continuation.finish(throwing: GQLError.missingData)
                            return
                        }
                        continuation.yield(data)
                }
            }
            
            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
