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

    // MARK: - Existing action feedback popup API
    @Published public var currentActionFeedbackType: ActionFeedbackType?
    @Published public var confirmAction: (() async throws -> Void)?
    @Published public var cancelAction: (() -> Void)?

    // MARK: - Feedback Prompt
    @Published public var isShowingFeedbackPrompt = false
    private var feedbackTask: Task<Void, Never>?

    public let feedbackFormURL = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSeTRecbfUTKmpYHSaE7bSawEagUpkOPagJtLqZdsec659HaGw/viewform")!

    // Session anchor (time when we consider the session started)
    private var sessionStart: Date?

    private init() {}

    // MARK: - Existing action feedback API
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

// MARK: - Feedback Prompt

extension PopupManager {

    /// Mark the beginning of a user session (used for the 30s rule).
    public func beginFeedbackSession(at date: Date = Date()) {
        // Only set once per app-visible session
        if sessionStart == nil { sessionStart = date }
    }

    /// Schedule the feedback prompt if allowed by rules (except the 30s rule).
    /// Sleeps ONLY for the remaining time to hit 30s since `sessionStart`.
    public func scheduleFeedbackPromptIfEligible() {
        guard isEligibleIgnoringSessionLength(now: Date()) else { return }
        guard let sessionStart else {
            // If someone forgot to call `beginFeedbackSession()`, do it now.
            self.sessionStart = Date()
            // We still continue scheduling using the freshly set start.
            return scheduleFeedbackPromptIfEligible()
        }

        cancelPendingFeedbackPrompt()

        let now = Date()
        let elapsed = now.timeIntervalSince(sessionStart)
        let remaining = max(0, 30 - elapsed) // seconds to reach 30s

        feedbackTask = Task { [weak self] in
            guard let self else { return }
            do {
                if remaining > 0 {
                    let nanos = UInt64(remaining * 1_000_000_000)
                    try await Task.sleep(nanoseconds: nanos)
                }
                // If cancelled during sleep, bail out
                try Task.checkCancellation()
            } catch {
                return
            }

            await MainActor.run {
                self.tryPresentFeedbackPrompt(now: Date())
                self.feedbackTask = nil
            }
        }
    }

    /// Cancel any queued presentation (e.g. when backgrounding or opting out).
    public func cancelPendingFeedbackPrompt() {
        feedbackTask?.cancel()
        feedbackTask = nil
    }

    /// Present if ALL rules pass (incl. 30s session).
    public func tryPresentFeedbackPrompt(now: Date = Date()) {
        guard shouldShowFeedbackPrompt(now: now) else { return }

        incrementShownCount()
        setLastShown(date: now)

        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingFeedbackPrompt = true
        }
    }

    /// Hide and cancel pending timers.
    public func hideFeedbackPrompt() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowingFeedbackPrompt = false
        }
        cancelPendingFeedbackPrompt()
    }

    /// Set "Do not show again" and cancel queued show if any.
    public func setFeedbackDontShowAgain(_ value: Bool) {
        defaults.set(value, forKey: Keys.dontShowAgain)
        if value { cancelPendingFeedbackPrompt() }
    }

    // MARK: - Rules

    /// Full rules:
    /// - not "do not show again"
    /// - shown < 3 times
    /// - last shown ≥ 5 days ago (or never)
    /// - session ≥ 30 seconds  (we implement as `now.timeIntervalSince(sessionStart) < 30 == false`)
    private func shouldShowFeedbackPrompt(now: Date) -> Bool {
        guard let sessionStart else { return false }

        if defaults.bool(forKey: Keys.dontShowAgain) { return false }
        if defaults.integer(forKey: Keys.shownCount) >= 3 { return false }

        if let last = defaults.object(forKey: Keys.lastShown) as? Date {
            if now.timeIntervalSince(last) < 5 * 24 * 60 * 60 { return false }
        }

        if now.timeIntervalSince(sessionStart) < 30 { return false }
        return true
    }

    /// Pre-flight rules (skip only the 30s session part)
    private func isEligibleIgnoringSessionLength(now: Date) -> Bool {
        if defaults.bool(forKey: Keys.dontShowAgain) { return false }
        if defaults.integer(forKey: Keys.shownCount) >= 3 { return false }
        if let last = defaults.object(forKey: Keys.lastShown) as? Date {
            if now.timeIntervalSince(last) < 5 * 24 * 60 * 60 { return false }
        }
        return true
    }

    // MARK: - Storage

    private var defaults: UserDefaults {
        UserDefaults(suiteName: "group.eu.peernetwork.PeerApp") ?? .standard
    }

    private enum Keys {
        static let dontShowAgain = "feedbackPopup_dontShowAgain"
        static let shownCount    = "feedbackPopup_shownCount"
        static let lastShown     = "feedbackPopup_lastShown"
    }

    private func incrementShownCount() {
        let c = defaults.integer(forKey: Keys.shownCount)
        defaults.set(c + 1, forKey: Keys.shownCount)
    }

    private func setLastShown(date: Date) {
        defaults.set(date, forKey: Keys.lastShown)
    }

    // MARK: - Debug helpers
    public func _resetFeedbackPromptState() {
        defaults.removeObject(forKey: Keys.dontShowAgain)
        defaults.removeObject(forKey: Keys.shownCount)
        defaults.removeObject(forKey: Keys.lastShown)
    }
}
