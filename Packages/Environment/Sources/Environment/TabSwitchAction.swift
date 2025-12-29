//
//  TabSwitchAction.swift
//  Environment
//
//  Created by Artem Vasin on 29.12.25.
//

import SwiftUI
import Models

public struct TabSwitchAction {
    public let action: @MainActor (AppTab) -> Void
    public init(_ action: @escaping @MainActor (AppTab) -> Void) { self.action = action }

    public func callAsFunction(_ tab: AppTab) {
        Task { @MainActor in action(tab) }
    }

    public static let noop = TabSwitchAction { _ in }
}

private struct TabSwitchActionKey: EnvironmentKey {
    static let defaultValue: TabSwitchAction = .noop
}

public extension EnvironmentValues {
    var tabSwitch: TabSwitchAction {
        get { self[TabSwitchActionKey.self] }
        set { self[TabSwitchActionKey.self] = newValue }
    }
}
