//
//  APIServiceWrapper.swift
//  FeedNew
//
//  Created by Alexander Savchenko on 04.04.25.
//

import Combine

@MainActor
public protocol APIServiceWrapper: ObservableObject {
    var apiService: APIService { get }
}
