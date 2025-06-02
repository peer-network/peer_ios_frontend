//
//  MainCoordinator.swift
//  PeerApp
//
//  Created by Artem Vasin on 23.05.25.
//

//import SwiftUI
//import Environment
//
//final class MainCoordinator {
//    struct Transitions {
//        let logout: () -> Void
//    }
//
//    @Binding var navigationPath: NavigationPath
//
//    private let id: UUID
//    private let transitions: Transitions?
//
//    init(navigationPath: Binding<NavigationPath>, transitions: Transitions? = nil) {
//        id = UUID()
//        self.transitions = transitions
//        self._navigationPath = navigationPath
//    }
//
//    @MainActor
//    @ViewBuilder
//    func view(selectedTab: Binding<AppTab>, appRouter: Router) -> some View {
//        ContentView(selectedTab: selectedTab, appRouter: appRouter)
//    }
//}
//
//extension MainCoordinator: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//
//    static func == (lhs: MainCoordinator, rhs: MainCoordinator) -> Bool {
//        lhs.id == rhs.id
//    }
//}
