//
//  View+Extensions.swift
//  DesignSystem
//
//  Created by Артем Васин on 19.12.24.
//

import SwiftUI

public extension View {
    /// Conditionally applies a transformation to a view if the condition is true.
    ///
    /// - Parameters:
    ///   - condition: A Boolean value that determines if the transformation should be applied.
    ///   - transform: A closure that applies a transformation to the view.
    /// - Returns: Either the original view or the transformed view.
    @ViewBuilder
    func ifCondition<Transform: View> (_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

public extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> some View { block(self) }
}

public extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: - Popup extensions

public extension View {
    /// Gets the screen dimensions as a CGRect.
    ///
    /// - Returns: The dimensions of the main screen.
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }

    /// Retrieves the root UIViewController of the current window.
    ///
    /// - Returns: The root UIViewController or a default initialized one if unavailable.
    func getRootController() -> UIViewController {

        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.last?.rootViewController else {
            return .init()
        }

        return root
    }

    /// Displays a popup view for a brief period.
    func showPopup(text: String, icon: Image? = nil, backIcon: Image? = nil) {
        // Converting SwiftUI view to UIKit
        let popupViewController = UIHostingController(rootView: PopupView(text: text, frontIcon: icon, backIcon: backIcon))
        // Content size
        let size = popupViewController.view.intrinsicContentSize

        // Position the popup at the top-center of the screen
        popupViewController.view.frame.size = size
        popupViewController.view.frame.origin = CGPoint(x: (getRect().width / 2) - (size.width / 2), y: 64)

        popupViewController.view.backgroundColor = .clear

        // Add popup to the root view controller's view
        getRootController().view.addSubview(popupViewController.view)

        // Automatically remove the popup
        Task { @MainActor in
            try await Task.sleep(nanoseconds: UInt64(5.0 * Double(NSEC_PER_SEC)))

            // Remove the popup from the view
            popupViewController.view.removeFromSuperview()
        }
    }
}
