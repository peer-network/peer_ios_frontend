//
//  InjectedPropertyWrapper.swift
//  PeerApp
//
//  Created by Artem Vasin on 09.05.25.
//

@propertyWrapper
struct Injected<Dependency> {
    var wrappedValue: Dependency

    init() {
        wrappedValue = DependencyProvider.shared.container.resolve(Dependency.self)!
    }
}
