//
//  Constants.swift
//  Chat
//
//  Created by Siva kumar Aketi on 10/06/25.
//
import SwiftUI

struct Constants {
    
    // MARK: - Chat View
    struct ToggleViewChat {
        static let privateTitle = "Private"
        static let groupTitle = "Group Chats"
        static let plusTitle = "plus"
        static let chatAccessibilityTitle = "Add new chat"
        static let addChatAccessibilityButton = "Add new chat"
        static let toggleAccessibilityButtonHint = "Switches between chat types"
    }
}
extension Constants {
    struct ToggleViewChatPadding {
        static let horizontal: CGFloat = 20
        static let vertical: CGFloat = 10
        static let toggleHorizontal: CGFloat = 20
        static let toggleVertical: CGFloat = 10
        static let icon: CGFloat = 12
    }
    
    struct Spacing {
        static let toggleView: CGFloat = 16
    }
    
    struct Fonts {
           static let toggleFont = Font.custom("Inter-Bold", size: 14)
           static let buttonFont = Font.custom("Inter-Bold", size: 14)
       }
       
    struct ButtonSize {
           static let toggleHeight: CGFloat = 50
           static let addButton: CGFloat = 50
       }
    struct Colors {
            static let selectedBackground = Color(hex: "#323232")
            static let unselectedBackground = Color(hex: "#323232")
            static let selectedText = Color.white
            static let unselectedText = Color.gray
            static let buttonForeground = Color.white
            static let buttonBackground = Color.blue
        }
    struct FontSize {
        static let toggleButton: CGFloat = 14
    }
   
}
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
