//
//  HapticManager.swift
//  Environment
//
//  Created by Артем Васин on 19.12.24.
//

import CoreHaptics
import UIKit

@MainActor
public final class HapticManager {
    public enum HapticType {
        case buttonPress
        case dataRefresh(intensity: CGFloat)
        case notification(_ type: UINotificationFeedbackGenerator.FeedbackType)
        case tabSelection
        case feed
    }
    
    public static let shared = HapticManager()
    
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    public var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }
    
    private init() {
        selectionGenerator.prepare()
        impactGenerator.prepare()
    }
    
    public func fireHaptic(_ type: HapticType) {
        guard supportsHaptics else { return }
        
        switch type {
            case .buttonPress:
                impactGenerator.impactOccurred()
            case let .dataRefresh(intensity):
                impactGenerator.impactOccurred(intensity: intensity)
            case let .notification(type):
                notificationGenerator.notificationOccurred(type)
            case .tabSelection:
                selectionGenerator.selectionChanged()
            case .feed:
                selectionGenerator.selectionChanged()
        }
    }
}
