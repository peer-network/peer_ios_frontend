//
//  SystemPopupManager.swift
//  DesignSystem
//
//  Created by Artem Vasin on 28.10.25.
//

import SwiftUI

@MainActor
public class SystemPopupManager: ObservableObject {
    public static let shared = SystemPopupManager()

    @Published public var presentedPopupBuilder: (() -> AnyView)? = nil

    private init() {}

    public func presentPopup(_ type: SystemPopupType,
                             confirmation: @escaping () -> Void,
                             cancel: (() -> Void)? = nil) {
        presentedPopupBuilder = { [weak self] in
            AnyView(
                SystemPopupView(
                    type: type,
                    confirmation: {
                        self?.dismiss()
                        confirmation()
                    },
                    cancel: {
                        self?.dismiss()
                        cancel?()
                    }
                )
            )
        }
    }

    public func dismiss() {
        presentedPopupBuilder = nil
    }
}
