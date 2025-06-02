//
//  SplashView.swift
//  PeerApp
//
//  Created by Artem Vasin on 23.05.25.
//

//import SwiftUI
//import DesignSystem
//
//struct SplashView: View {
//
//    @StateObject private var viewModel: SplashViewModel
//
//    init(viewModel: SplashViewModel) {
//        _viewModel = StateObject(wrappedValue: viewModel)
//    }
//
//    var body: some View {
//        ZStack(alignment: .center) {
//            Colors.textActive
//                .ignoresSafeArea()
//
//            LottieView(animation: .splashScreenLogo, speed: 1.2, onLoopComplete: {})
//                .frame(width: UIScreen.main.bounds.width * 0.6)
//        }
//        .onAppear { viewModel.viewAppeared() }
//    }
//}
