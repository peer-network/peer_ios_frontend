//
//  AppCoordinator.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var currentCoordinator: Coordinator?
    

    init() {
        start()
    }
    
    func start() {
        currentCoordinator = ChatCoordinator(parentCoordinator: self)
    }
}
