//
//  DependencyProvider.swift
//  PeerApp
//
//  Created by Artem Vasin on 09.05.25.
//

import Swinject

final class DependencyProvider {
    static let shared = DependencyProvider()

    let container: Container
    private let assembler: Assembler

    private init() {
        container = Container()
        assembler = Assembler(
            [
                ManagersAssembly()
            ],
            container: container
        )
    }
}
