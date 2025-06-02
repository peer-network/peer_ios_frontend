//
//  ManagersAssembly.swift
//  PeerApp
//
//  Created by Artem Vasin on 09.05.25.
//

import Swinject
import Models
import Networking
import Environment
import TokenKeychainManager

final class ManagersAssembly: Assembly {
    func assemble(container: Container) {
        container.register(APIService.self) { r in
            APIServiceGraphQL()
        }
        .inObjectScope(.container)

//        container.register(AccountManagerProtocol.self) { r in
//            let apiService = r.resolve(APIService.self)!
//
//            return AccountManager(apiService: apiService)
//        }
//        .inObjectScope(.container)
//
//        container.register(TokenKeychainManagerProtocol.self) { r in
//            TokenKeychainManager()
//        }
//        .inObjectScope(.container)
//
//        container.register(AuthManagerProtocol.self) { r in
//            let accManager = r.resolve(AccountManagerProtocol.self)!
//            let tokenManager = r.resolve(TokenKeychainManagerProtocol.self)!
//
//            return AuthManager(accountManager: accManager, tokenManager: tokenManager)
//        }
    }
}
