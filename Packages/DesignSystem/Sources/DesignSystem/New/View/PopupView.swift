//
//  PopupView.swift
//  DesignSystem
//
//  Created by Артем Васин on 04.02.25.
//

import SwiftUI

public struct PopupView: View {
    private let text: String
    @ViewBuilder private let frontIcon: Image?
    @ViewBuilder private let backIcon: Image?

    // Animating
    @State private var show: Bool = false

    public init(
        text: String,
        frontIcon: Image? = nil,
        backIcon: Image? = nil
    ) {
        self.text = text
        self.frontIcon = frontIcon
        self.backIcon = backIcon
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 5) {
            if let frontIcon {
                frontIcon
                    .iconSize(height: 17)
                    .foregroundStyle(Color.white)
                    .padding(.trailing, 5)
            }
            
            Text(text)
                .font(.customFont(weight: .regular, size: .footnoteSmall))
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.white)

            if let backIcon {
                backIcon
                    .iconSize(height: 17)
                    .foregroundStyle(Color.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background {
            BlurView(style: .systemThinMaterialDark)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.white, lineWidth: 1)
        )
        // Moving to the top
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .offset(y: show ? 18 : -200)
        .onAppear {
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.5)) {
                    show = true
                }
                
                // Wait for 2.5 seconds
                try await Task.sleep(nanoseconds: UInt64(2.5 * Double(NSEC_PER_SEC)))
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    show = false
                }
            }
        }
    }
}

private struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 0.5)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    ZStack {
        Color.white
            .ignoresSafeArea()
        
        PopupView(
            text: "You used 1 comment! Free comments left for today: 2",
            frontIcon: Icons.heartFill,
            backIcon: Icons.logoCircleWhite
        )
    }
}
