//
//  RemoteConfigError.swift
//  RemoteConfig
//
//  Created by Artem Vasin on 10.04.25.
//

public enum RemoteConfigError: Error {
    case fetchError(Error)
    case activationError(Error)
    case keyNotFound(String)
    case typeMismatch(String)
    case configUpdateError(Error)
}
