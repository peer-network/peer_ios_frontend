//
//  InjectedPropertyWrapper.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

@propertyWrapper struct Injected<Dependency> {
    var wrappedValue: Dependency

    init() {
        wrappedValue = DependencyProvider.shared.container.resolve(Dependency.self)!
    }
}
