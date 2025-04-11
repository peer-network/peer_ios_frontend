//
//  SafariRouter.swift
//  PeerApp
//
//  Created by Артем Васин on 09.01.25.
//

import SwiftUI
import DesignSystem
import Environment
import SafariServices

extension View {
    func withSafariRouter() -> some View {
        modifier(SafariRouter())
    }
}

private struct SafariRouter: ViewModifier {
    @EnvironmentObject private var router: Router
    
    @StateObject private var safariManager = InAppSafariManager()
    
    func body(content: Content) -> some View {
        content
            .environment(
                \.openURL,
                 OpenURLAction { url in
                     // Open internal URL.
                     return router.handle(url: url)
                 }
            )
        // TODO: Add deeplinks here too when they are ready
            .onAppear {
                router.urlHandler = { url in
//                    guard userPreferences.preferredBrowser == .inAppSafari else {
//                        return .systemAction
//                    }
                    // SFSafariViewController only supports http:// or https://.
                    guard let scheme = url.scheme,
                          ["http", "https"].contains(scheme.lowercased())
                    else {
                        return .systemAction
                    }

                    return safariManager.open(url)
                }
            }
    }
}

@MainActor
private class InAppSafariManager: NSObject, SFSafariViewControllerDelegate, ObservableObject {
    /// We keep a reference to the temporary UIWindow used to present Safari
    private var window: UIWindow?
    
    func open(_ url: URL) -> OpenURLAction.Result {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController
        else {
            return .systemAction
        }

        let configuration = SFSafariViewController.Configuration()
        let safariVC = SFSafariViewController(url: url, configuration: configuration)
        safariVC.preferredBarTintColor = .launchScreenBackground
        safariVC.delegate = self

        rootVC.present(safariVC, animated: true)

        return .handled
    }

    func dismiss() {
        window?.rootViewController?.presentedViewController?.dismiss(animated: true) { [weak self] in
            self?.window?.resignKey()
            self?.window?.isHidden = true
            self?.window = nil
        }
    }
    
    /// Creates or reuses a temporary UIWindow for presentation.
    private func setupWindow(in windowScene: UIWindowScene) -> UIWindow {
        let window = self.window ?? UIWindow(windowScene: windowScene)
        let hostingVC = UIViewController()
        window.rootViewController = hostingVC
        window.windowLevel = .alert + 1
        window.makeKeyAndVisible()
        window.overrideUserInterfaceStyle = .dark
        
        self.window = window
        return window
    }
    
    // MARK: - SFSafariViewControllerDelegate
    nonisolated func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        Task { @MainActor in
            dismiss()
        }
    }
}
