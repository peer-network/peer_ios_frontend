//
//  Coordinator.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
} 
