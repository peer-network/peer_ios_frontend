//
//  SplashViewModel.swift
//  PeerApp
//
//  Created by Alexander Savchenko on 11.04.25.
//

import Combine
import Environment

@MainActor
final class SplashViewModel: ObservableObject {
    struct Transitions {
        let initCompleted: (_ restored: Bool) -> Void
    }
    
    @Published private var state: AuthState = .loading

    private var cancellables = Set<AnyCancellable>()
    private let authManager: AuthManagerProtocol
    private let transitions: Transitions?
    
    init(authManager: AuthManagerProtocol, transitions: Transitions? = nil) {
        self.authManager = authManager
        self.transitions = transitions
    }
    
    func viewAppeared() {
        $state.sink { [weak self] state in
            switch state {
            case .loading:
                break
            case .unauthenticated:
                self?.transitions?.initCompleted(false)
            case .authenticated:
                self?.transitions?.initCompleted(true)
            }
        }
        .store(in: &cancellables)
        
        Task {
            state = await authManager.restoreSessionIfPossible()
        }
    }
}
