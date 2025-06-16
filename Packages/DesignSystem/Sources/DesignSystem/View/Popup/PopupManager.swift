//
//  PopupManager.swift
//  Environment
//
//  Created by Artem Vasin on 16.06.25.
//

import SwiftUI

@MainActor
public final class PopupManager: ObservableObject {
    public static let shared = PopupManager()
    
    @Published public var currentActionFeedbackType: ActionFeedbackType?
    @Published public var confirmAction: (() async throws -> Void)?
    @Published public var cancelAction: (() -> Void)?
    
    private init() {}
    
    public func showActionFeedback(
        type: ActionFeedbackType,
        confirm: @escaping () async throws -> Void,
        cancel: (() -> Void)? = nil
    ) {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentActionFeedbackType = type
            confirmAction = confirm
            cancelAction = cancel
        }
    }
    
    public func hideActionFeedbackPopup() {
        currentActionFeedbackType = nil
        confirmAction = nil
        cancelAction = nil
    }
}
