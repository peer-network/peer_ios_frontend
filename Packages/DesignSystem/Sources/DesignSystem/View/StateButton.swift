//
//  StateButton.swift
//  DesignSystem
//
//  Created by Artem Vasin on 20.06.25.
//

import SwiftUI

public struct StateButtonConfig: Equatable {
    var buttonSize: ButtonSize
    var buttonType: ButtonType
    var title: String
    var icon: Image?
    var iconPlacement: IconPlacement?

    var buttonStyle: some ButtonStyle {
        let style: any ButtonStyle
        switch buttonType {
            case .primary:
                style = TargetStyle(backgroundStyle: buttonType.fillStyle, textColor: buttonType.textColor, height: buttonSize.height, font: buttonSize.font)
            case .secondary:
                style = TargetStyle(backgroundStyle: buttonType.fillStyle, textColor: buttonType.textColor, height: buttonSize.height, font: buttonSize.font)
            case .teritary:
                style = StrokeStyle(strokeStyle: buttonType.fillStyle, textColor: buttonType.textColor, height: buttonSize.height, font: buttonSize.font)
            case .alert:
                style = StrokeStyle(strokeStyle: buttonType.fillStyle, textColor: buttonType.textColor, height: buttonSize.height, font: buttonSize.font)
            case .custom:
                style = TargetStyle(backgroundStyle: buttonType.fillStyle, textColor: buttonType.textColor, height: buttonSize.height, font: buttonSize.font)
        }
        return AnyButtonStyle(style)
    }

    public init(
        buttonSize: ButtonSize,
        buttonType: ButtonType,
        title: String,
        icon: Image? = nil,
        iconPlacement: IconPlacement? = nil
    ) {
        self.buttonSize = buttonSize
        self.buttonType = buttonType
        self.title = title
        self.icon = icon
        self.iconPlacement = iconPlacement
    }

    public enum IconPlacement {
        case leading, trailing
    }
}

public struct StateButton: View {
    var config: StateButtonConfig
    var action: () -> ()

    private let iconSize: CGFloat = 24

    public init(
        config: StateButtonConfig,
        action: @escaping () -> Void
    ) {
        self.config = config
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: config.buttonSize.spacingBetweenTitleAndIcon) {
                if let icon = config.icon, case .leading = config.iconPlacement {
                    icon
                        .iconSize(width: iconSize, height: iconSize)
                }

                Text(config.title)

                if let icon = config.icon, case .trailing = config.iconPlacement {
                    icon
                        .iconSize(width: iconSize, height: iconSize)
                }
            }
        }
        .buttonStyle(config.buttonStyle)
    }
}

public struct AsyncStateButton: View {
    var config: StateButtonConfig
    var action: () async -> ()

    private let animation: Animation = .easeInOut(duration: 0.25)

    @State private var isLoading: Bool = false

    private let iconSize: CGFloat = 24

    public init(
        config: StateButtonConfig,
        action: @escaping () async -> Void
    ) {
        self.config = config
        self.action = action
    }

    public var body: some View {
        Button {
            Task {
                isLoading = true
                await action()
                isLoading = false
            }
        } label: {
            HStack(spacing: 10) {
                if isLoading {
//                    Text("Loading...")

                    Spinner(tint: config.buttonType.textColor, lineWidth: 4)
                        .frame(width: 20, height: 20)
                        .transition(.blurReplace)
                } else {
                    if let icon = config.icon, case .leading = config.iconPlacement {
                        icon
                            .iconSize(width: iconSize, height: iconSize)
                    }

                    Text(config.title)

                    if let icon = config.icon, case .trailing = config.iconPlacement {
                        icon
                            .iconSize(width: iconSize, height: iconSize)
                    }
                }
            }
        }
        .disabled(isLoading)
        .buttonStyle(config.buttonStyle)
        .animation(animation, value: config)
        .animation(animation, value: isLoading)
    }
}

// MARK: - Button styles

public enum ButtonSize {
    case small
    case large

    var height: CGFloat {
        switch self {
            case .small: return 40
            case .large: return 60
        }
    }

    var font: AppFont {
        switch self {
            case .small:
                return .bodyRegular
            case .large:
                return .buttonRegular
        }
    }

    var spacingBetweenTitleAndIcon: CGFloat {
        switch self {
            case .small:
                return 20
            case .large:
                return 10
        }
    }
}

public enum ButtonType: Equatable {
    case primary
    case secondary
    case teritary
    case alert
    case custom(textColor: Color, fillColor: Color)

    var fillStyle: some ShapeStyle {
        let style: any ShapeStyle
        switch self {
            case .primary: style = Colors.hashtag
            case .secondary: style = Colors.whitePrimary
            case .teritary: style = Colors.whitePrimary
            case .alert: style = Colors.redAccent
            case .custom(_, let fillColor): style = fillColor
        }
        return AnyShapeStyle(style)
    }

    var textColor: Color {
        switch self {
            case .primary:
                return Colors.whitePrimary
            case .secondary:
                return Colors.inactiveDark
            case .teritary:
                return Colors.whitePrimary
            case .alert:
                return Colors.redAccent
            case .custom(let textColor, _):
                return textColor
        }
    }
}

struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView

    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { configuration in
            AnyView(style.makeBody(configuration: configuration))
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

// Wrapper to be able to access @Environment(\.isEnabled)
public struct ButtonStyleContent<Content: View>: View {

    public init(@ViewBuilder viewBuilder: @escaping ContentBuilder) {
        self.viewBuilder = viewBuilder
    }

    public typealias ContentBuilder = (_ isEnabled: Bool) -> Content

    private let viewBuilder: ContentBuilder

    @Environment(\.isEnabled) public var isEnabled: Bool

    public var body: some View {
        viewBuilder(isEnabled)
    }
}

struct StrokeStyle<S: ShapeStyle>: ButtonStyle {
    let strokeStyle: S
    let textColor: Color
    let height: CGFloat
    let font: AppFont

    func makeBody(configuration: Configuration) -> some View {
        ButtonStyleContent { isEnabled in
            configuration.label
                .appFont(font)
                .foregroundStyle(textColor)
                .padding(.horizontal, 20)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .background {
                    Colors.blackDark

                    RoundedRectangle(cornerRadius: 30)
                        .strokeBorder(strokeStyle, lineWidth: 1)
                }
                .overlay {
                    if !isEnabled {
                        Color.black.opacity(0.3)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .contentShape(Rectangle())
                .animation(.linear(duration: 0.2)) {
                    $0.scaleEffect(configuration.isPressed ? 0.9 : 1)
                }
        }
    }
}

struct TargetStyle<S: ShapeStyle>: ButtonStyle {
    let backgroundStyle: S
    let textColor: Color
    let height: CGFloat
    let font: AppFont

    func makeBody(configuration: Configuration) -> some View {
        ButtonStyleContent { isEnabled in
            configuration.label
                .appFont(font)
                .bold()
                .foregroundStyle(textColor)
                .padding(.horizontal, 20)
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .background(backgroundStyle)
                .overlay {
                    if !isEnabled {
                        Color.black.opacity(0.3)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .contentShape(Rectangle())
                .animation(.linear(duration: 0.2)) {
                    $0.scaleEffect(configuration.isPressed ? 0.9 : 1)
                }
        }
    }
}


// MARK: - Spinner

fileprivate struct Spinner: View {
    var tint: Color
    var lineWidth: CGFloat = 4

    // View Properties
    @State private var rotation: Double = 0
    @State private var extraRotation: Double = 0
    @State private var isAnimatedTriggered: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.3), style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))

            Circle()
                .trim(from: 0, to: 0.3)
                .stroke(tint, style: .init(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .rotationEffect(.init(degrees: rotation))
                .rotationEffect(.init(degrees: extraRotation))
        }
        .compositingGroup()
        .onAppear(perform: animate)
    }

    private func animate() {
        guard !isAnimatedTriggered else { return }
        isAnimatedTriggered = true

        withAnimation(.linear(duration: 0.7).speed(1.2).repeatForever(autoreverses: false)) {
            rotation += 360
        }

        withAnimation(.linear(duration: 1).speed(1.2).delay(1).repeatForever(autoreverses: false)) {
            extraRotation += 360
        }
    }
}
