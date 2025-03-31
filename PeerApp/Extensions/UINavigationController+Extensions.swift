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

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
