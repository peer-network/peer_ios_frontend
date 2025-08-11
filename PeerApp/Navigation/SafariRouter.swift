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
            .environment(\.openURL, OpenURLAction { url in
                router.handle(url: url)
            })
            .onAppear {
                router.urlHandler = { [weak safariManager] url in
                    safariManager?.handleURL(url) ?? .systemAction
                }
            }
            .onDisappear {
                router.urlHandler = nil
            }
    }
}

@MainActor
private class InAppSafariManager: NSObject, ObservableObject {
    private weak var presentationController: UIViewController?

    func handleURL(_ url: URL) -> OpenURLAction.Result {
        guard url.isWebURL else {
            return .systemAction
        }

        guard let rootViewController = topViewController() else {
            return .systemAction
        }

        return presentSafariViewController(with: url, from: rootViewController)
    }

    private func presentSafariViewController(with url: URL, from presenter: UIViewController) -> OpenURLAction.Result {
        let configuration = SFSafariViewController.Configuration()
        configuration.barCollapsingEnabled = true

        let safariViewController = SFSafariViewController(url: url, configuration: configuration)
        safariViewController.preferredBarTintColor = .launchScreenBackground
        safariViewController.preferredControlTintColor = .white
        safariViewController.delegate = self

        presenter.present(safariViewController, animated: true)
        presentationController = presenter

        return .handled
    }

    private func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else {
            return nil
        }

        return windowScene.windows
            .first(where: \.isKeyWindow)?
            .rootViewController?
            .topmostPresentedViewController
    }
}

// MARK: - SFSafariViewControllerDelegate
extension InAppSafariManager: SFSafariViewControllerDelegate {
    nonisolated func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        Task { @MainActor [weak self] in
            self?.presentationController?.dismiss(animated: true)
            self?.presentationController = nil
        }
    }
}

// MARK: - URL Extension
private extension URL {
    var isWebURL: Bool {
        guard let scheme = scheme?.lowercased() else { return false }
        return ["http", "https"].contains(scheme)
    }
}

// MARK: - UIViewController Extension
private extension UIViewController {
    var topmostPresentedViewController: UIViewController {
        presentedViewController?.topmostPresentedViewController ?? self
    }
}
