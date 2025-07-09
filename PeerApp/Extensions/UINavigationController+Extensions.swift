//
//  UINavigationController+Extensions.swift
//  PeerApp
//
//  Created by Artem Vasin on 11.03.25.
//

import UIKit

// to still have a swipe gesture to go back while the navigation bar is hidden
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    // Allows swipe back gesture after hiding standard navigation bar with .navigationBarHidden(true).

    public func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        guard viewControllers.count > 1 else { return false }

        // Prevent gesture conflicts during sheet presentation
        // Check if any presented view controller exists
        if presentedViewController != nil {
            return false
        }

        return true
    }

    // Allows interactivePopGestureRecognizer to work simultaneously with other gestures.

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    // Blocks other gestures when interactivePopGestureRecognizer begins

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
