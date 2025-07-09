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
    case graphQLErrors([GraphQLError])
}

public protocol GQLClientConfigurable {
    var apiEndpointURL: URL { get }
}

public class GQLClient {
    static public private(set) var shared: GQLClient!

    public let apolloClient: ApolloClient
    private var currentEndpointURL: URL

    private init(endpointURL: URL) {
        self.currentEndpointURL = endpointURL
        self.apolloClient = GQLClient.createApolloClient(with: endpointURL)
    }

    public static func configure(with config: GQLClientConfigurable) {
        shared = GQLClient(endpointURL: config.apiEndpointURL)
    }

    private static func createApolloClient(with endpointURL: URL) -> ApolloClient {
        let store = ApolloStore(cache: InMemoryNormalizedCache())
        let provider = NetworkInterceptorProvider(store: store)
        let transport = RequestChainNetworkTransport(interceptorProvider: provider, endpointURL: endpointURL)

        let webSocket = WebSocket(url: endpointURL, protocol: .graphql_ws)
        let webSocketTransport = WebSocketTransport(websocket: webSocket)

        let splitTransport = SplitNetworkTransport(uploadingNetworkTransport: transport, webSocketNetworkTransport: webSocketTransport)

        return ApolloClient(networkTransport: splitTransport, store: store)
    }

    public func fetch<Query>(query: Query, cachePolicy: CachePolicy = .returnCacheDataElseFetch) async throws -> Query.Data where Query: GraphQLQuery {
        try await withCheckedThrowingContinuation { continuation in
            var queryAlreadyCompletedOnce = false
            apolloClient.fetch(query: query, cachePolicy: cachePolicy) { result in
                guard !queryAlreadyCompletedOnce else { return }
                queryAlreadyCompletedOnce = true
                switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(result):
                        if let data = result.data {
                            continuation.resume(returning: data)
                        } else if let errors = result.errors {
                            continuation.resume(throwing: GQLError.graphQLErrors(errors))
                        }
                }
            }
        }
    }

    public func mutate<Mutation>(mutation: Mutation) async throws -> Mutation.Data where Mutation: GraphQLMutation {
        try await withCheckedThrowingContinuation { continuation in
            apolloClient.perform(mutation: mutation) { result in
                switch result {
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    case let .success(result):
                        if let data = result.data {
                            continuation.resume(returning: data)
                        } else if let errors = result.errors {
                            continuation.resume(throwing: GQLError.graphQLErrors(errors))
                        }
                }
            }
        }
    }

    public func subscribe<Subscription>(subscription: Subscription) -> AsyncThrowingStream<Subscription.Data, Error> where Subscription: GraphQLSubscription {
        AsyncThrowingStream { continuation in
            let cancellable = apolloClient.subscribe(subscription: subscription) { result in
                switch result {
                    case let .failure(error):
                        continuation.finish(throwing: error)
                    case let .success(result):
                        if let data = result.data {
                            continuation.yield(data)
                        } else if let errors = result.errors {
                            continuation.finish(throwing: GQLError.graphQLErrors(errors))
                        }
                }
            }

            continuation.onTermination = { _ in
                cancellable.cancel()
            }
        }
    }
}
