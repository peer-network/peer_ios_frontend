//
//  Theme.swift
//  DesignSystem
//
//  Created by Артем Васин on 20.12.24.
//

import SwiftUI

@MainActor
public final class Theme: ObservableObject {
    class Storage {
        enum ThemeKey: String {
            case colorScheme, tint, label, primaryBackground, secondaryBackground
            case avatarPosition, avatarShape, postActionsDisplay, postMediaStyle
            case selectedSet, selectedScheme
            case followSystemColorSchme
            case displayFullUsernameTimeline
            case lineSpacing
            case statusActionSecondary
            case contentGradient
            case compactLayoutPadding
        }
        
        @AppStorage("is_previously_set") public var isThemePreviouslySet: Bool = false
        @AppStorage(ThemeKey.followSystemColorSchme.rawValue) public var followSystemColorScheme: Bool = true
        @AppStorage(ThemeKey.selectedScheme.rawValue) public var selectedScheme: ColorScheme = .dark
        @AppStorage(ThemeKey.primaryBackground.rawValue) var primaryBackgroundColor: Color = .white
        @AppStorage(ThemeKey.secondaryBackground.rawValue) var secondaryBackgroundColor: Color = .gray
        @AppStorage(ThemeKey.tint.rawValue) public var tintColor: Color = .black
        
        @AppStorage(ThemeKey.label.rawValue) public var labelColor: Color = .black
        
        @AppStorage(ThemeKey.selectedSet.rawValue) var storedSet: ColorSetName = .peerDark
        
        @AppStorage(ThemeKey.avatarShape.rawValue) var avatarShape: AvatarShape = .circle
        @AppStorage(ThemeKey.avatarPosition.rawValue) var avatarPosition: AvatarPosition = .leading
        @AppStorage(ThemeKey.postActionsDisplay.rawValue) public var postActionsDisplay: PostActionsDisplay = .full
        @AppStorage(ThemeKey.postMediaStyle.rawValue) public var postMediaStyle: PostMediaStyle = .large
        
        @AppStorage(ThemeKey.lineSpacing.rawValue) public var lineSpacing: Double = 1.2
        
        @AppStorage(ThemeKey.compactLayoutPadding.rawValue) public var compactLayoutPadding: Bool = true
        @AppStorage("font_size_scale") public var fontSizeScale: Double = 1
        @AppStorage("chosen_font") public var chosenFontData: Data?
        
        init() {}
    }
    
    let themeStorage = Storage()
    
    public enum FontState: Int, CaseIterable {
        case system
        case openDyslexic
        case hyperLegible
        case SFRounded
        case custom
        
        public var title: LocalizedStringKey {
            switch self {
                case .system:
                    "System"
                case .openDyslexic:
                    "Open Dyslexic"
                case .hyperLegible:
                    "Hyper Legible"
                case .SFRounded:
                    "SF Rounded"
                case .custom:
                    "Custom"
            }
        }
    }
    
    public enum AvatarShape: String, CaseIterable {
        case circle, rounded
        
        public var description: LocalizedStringKey {
            switch self {
                case .circle:
                    "Circle"
                case .rounded:
                    "Rounded"
            }
        }
    }
    
    public enum AvatarPosition: String, CaseIterable {
        case leading, top
        
        public var description: LocalizedStringKey {
            switch self {
                case .leading:
                    "Leading"
                case .top:
                    "Top"
            }
        }
    }
    
    public enum PostActionsDisplay: String, CaseIterable {
        case full, discret, none
        
        public var description: LocalizedStringKey {
            switch self {
                case .full:
                    "All"
                case .discret:
                    "Only buttons"
                case .none:
                    "No buttons"
            }
        }
    }
    
    public enum PostMediaStyle: String, CaseIterable {
        case large, medium, compact
        
        public var description: LocalizedStringKey {
            switch self {
                case .large:
                    "Large"
                case .medium:
                    "Medium"
                case .compact:
                    "Compact"
            }
        }
    }
    
    private var _cachedChoosenFont: UIFont?
    
    public var chosenFont: UIFont? {
        get {
            if let _cachedChoosenFont {
                return _cachedChoosenFont
            }
            guard let chosenFontData,
                  let font = try? NSKeyedUnarchiver.unarchivedObject(
                    ofClass: UIFont.self, from: chosenFontData)
            else { return nil }
            
            _cachedChoosenFont = font
            return font
        }
        set {
            if let font = newValue,
               let data = try? NSKeyedArchiver.archivedData(
                withRootObject: font, requiringSecureCoding: false)
            {
                chosenFontData = data
            } else {
                chosenFontData = nil
            }
            _cachedChoosenFont = nil
        }
    }
    
    @Published public private(set) var contrastingTintColor: Color
    
    // set contrastingTintColor to either labelColor or primaryBackgroundColor, whichever contrasts
    // better against the tintColor
    private func computeContrastingTintColor() {
        // A helper to compute luminance given a UIKit color
        func luminance(_ uiColor: UIColor) -> CGFloat {
            let ciColor = CIColor(color: uiColor)
            return 0.299 * ciColor.red + 0.587 * ciColor.green + 0.114 * ciColor.blue
        }
        
        // We’ll store resolved (or converted) UIColors here
        let resolvedTintColor: UIColor
        let resolvedLabelColor: UIColor
        let resolvedPrimaryBackgroundColor: UIColor
        
        // If iOS 17, we can use `Color.resolve(in:)` safely
        if #available(iOS 17.0, *) {
            let tint = tintColor.resolve(in: .init())
            let label = labelColor.resolve(in: .init())
            let primaryBackground = primaryBackgroundColor.resolve(in: .init())
            
            // Convert SwiftUI’s resolved color values to UIColor
            resolvedTintColor = UIColor(
                red: CGFloat(tint.red),
                green: CGFloat(tint.green),
                blue: CGFloat(tint.blue),
                alpha: CGFloat(tint.opacity)
            )
            resolvedLabelColor = UIColor(
                red: CGFloat(label.red),
                green: CGFloat(label.green),
                blue: CGFloat(label.blue),
                alpha: CGFloat(label.opacity)
            )
            resolvedPrimaryBackgroundColor = UIColor(
                red: CGFloat(primaryBackground.red),
                green: CGFloat(primaryBackground.green),
                blue: CGFloat(primaryBackground.blue),
                alpha: CGFloat(primaryBackground.opacity)
            )
            
        } else {
            // Fallback for iOS 16 and below: directly bridge SwiftUI Color to UIColor
            resolvedTintColor = UIColor(tintColor)
            resolvedLabelColor = UIColor(labelColor)
            resolvedPrimaryBackgroundColor = UIColor(primaryBackgroundColor)
        }
        
        // Calculate luminances
        let tintLuminance = luminance(resolvedTintColor)
        let labelLuminance = luminance(resolvedLabelColor)
        let primaryBackgroundLuminance = luminance(resolvedPrimaryBackgroundColor)
        
        // Compare which color is more contrasting to the tint
        if abs(tintLuminance - labelLuminance) > abs(tintLuminance - primaryBackgroundLuminance) {
            contrastingTintColor = labelColor
        } else {
            contrastingTintColor = primaryBackgroundColor
        }
    }
    
    
    @Published public var lineSpacing: Double {
        didSet {
            themeStorage.lineSpacing = lineSpacing
        }
    }
    
    @Published public var isThemePreviouslySet: Bool {
        didSet {
            themeStorage.isThemePreviouslySet = isThemePreviouslySet
        }
    }
    
    @Published public var followSystemColorScheme: Bool {
        didSet {
            themeStorage.followSystemColorScheme = followSystemColorScheme
        }
    }
    
    @Published public var selectedScheme: ColorScheme {
        didSet {
            themeStorage.selectedScheme = selectedScheme
        }
    }
    
    @Published public var primaryBackgroundColor: Color {
        didSet {
            themeStorage.primaryBackgroundColor = primaryBackgroundColor
            computeContrastingTintColor()
        }
    }
    
    @Published public var secondaryBackgroundColor: Color {
        didSet {
            themeStorage.secondaryBackgroundColor = secondaryBackgroundColor
        }
    }
    
    @Published public var tintColor: Color {
        didSet {
            themeStorage.tintColor = tintColor
            computeContrastingTintColor()
        }
    }
    
    @Published public var labelColor: Color {
        didSet {
            themeStorage.labelColor = labelColor
            computeContrastingTintColor()
        }
    }
    
    @Published public var avatarShape: AvatarShape {
        didSet {
            themeStorage.avatarShape = avatarShape
        }
    }
    
    @Published public var avatarPosition: AvatarPosition {
        didSet {
            themeStorage.avatarPosition = avatarPosition
        }
    }
    
    @Published public var postMediaStyle: PostMediaStyle {
        didSet {
          themeStorage.postMediaStyle = postMediaStyle
        }
      }
    
    private var storedSet: ColorSetName {
        didSet {
            themeStorage.storedSet = storedSet
        }
    }
    
    @Published public var postActionsDisplay: PostActionsDisplay {
        didSet {
            themeStorage.postActionsDisplay = postActionsDisplay
        }
    }
    
    @Published public var compactLayoutPadding: Bool {
        didSet {
            themeStorage.compactLayoutPadding = compactLayoutPadding
        }
    }
    
    @Published public private(set) var chosenFontData: Data? {
        didSet {
            themeStorage.chosenFontData = chosenFontData
        }
    }
    
    @Published public var fontSizeScale: Double {
        didSet {
            themeStorage.fontSizeScale = fontSizeScale
        }
    }
    
    @Published public var selectedSet: ColorSetName = .peerDark
    
    public static let shared = Theme()
    
    private init() {
        isThemePreviouslySet = themeStorage.isThemePreviouslySet
        avatarPosition = themeStorage.avatarPosition
        postActionsDisplay = themeStorage.postActionsDisplay
        followSystemColorScheme = themeStorage.followSystemColorScheme
        selectedScheme = themeStorage.selectedScheme
        primaryBackgroundColor = themeStorage.primaryBackgroundColor
        secondaryBackgroundColor = themeStorage.secondaryBackgroundColor
        tintColor = themeStorage.tintColor
        labelColor = themeStorage.labelColor
        avatarShape = themeStorage.avatarShape
        postMediaStyle = themeStorage.postMediaStyle
        compactLayoutPadding = themeStorage.compactLayoutPadding
        chosenFontData = themeStorage.chosenFontData
        fontSizeScale = themeStorage.fontSizeScale
        storedSet = themeStorage.storedSet
        lineSpacing = themeStorage.lineSpacing
        contrastingTintColor = .red
        selectedSet = storedSet
        
        computeContrastingTintColor()
    }
    
    public static var allColorSet: [ColorSet] {
        [
            PeerDark(),
            PeerLight(),
            PeerNeonDark(),
            PeerNeonLight(),
            DesertDark(),
            DesertLight(),
            NemesisDark(),
            NemesisLight(),
            MediumLight(),
            MediumDark(),
            ConstellationLight(),
            ConstellationDark(),
            ThreadsLight(),
            ThreadsDark(),
        ]
    }
    
    public func applySet(set: ColorSetName) {
        selectedSet = set
        setColor(withName: set)
    }
    
    public func setColor(withName name: ColorSetName) {
        let colorSet = Theme.allColorSet.filter { $0.name == name }.first ?? PeerDark()
        selectedScheme = colorSet.scheme
        tintColor = colorSet.tintColor
        primaryBackgroundColor = colorSet.primaryBackgroundColor
        secondaryBackgroundColor = colorSet.secondaryBackgroundColor
        labelColor = colorSet.labelColor
        storedSet = name
    }
    
    public func restoreDefault() {
        applySet(set: themeStorage.selectedScheme == .dark ? .peerDark : .peerLight)
        isThemePreviouslySet = true
        avatarPosition = .leading
        avatarShape = .circle
        postMediaStyle = .large
        storedSet = selectedSet
        postActionsDisplay = .full
        followSystemColorScheme = true
        lineSpacing = 1.2
        fontSizeScale = 1
        chosenFontData = nil
    }
}
