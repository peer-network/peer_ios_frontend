//
//  SystemPopupManager.swift
//  DesignSystem
//
//  Created by Artem Vasin on 28.10.25.
//

import SwiftUI
import Environment

@MainActor
public final class SystemPopupManager: SystemPopupManaging {
    public static let shared = SystemPopupManager()

    @Published public var presentedPopupBuilder: (() -> AnyView)? = nil

    private init() {}

    public func presentPopup(
        _ type: SystemPopupType,
        confirmation: @escaping () -> Void,
        cancel: (() -> Void)? = nil
    ) {
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

    public func presentCustomPopup<Content: View>(
        @ViewBuilder _ content: @escaping () -> Content
    ) {
        presentedPopupBuilder = { AnyView(content()) }
    }
    
    public func dismiss() {
        presentedPopupBuilder = nil
    }
}
