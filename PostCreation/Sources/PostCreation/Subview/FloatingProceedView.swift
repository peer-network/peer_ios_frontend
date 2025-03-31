//
//  FloatingProceedView.swift
//  PostCreation
//
//  Created by Artem Vasin on 03.03.25.
//

import SwiftUI
import DesignSystem

struct FloatingProceedView<Description: View, Proceed: View>: View {
    private let description: () -> Description
    private let proceed: () -> Proceed
    private let action: () -> Void
    private let disabled: Bool

    init(
        @ViewBuilder description: @escaping () -> Description,
        @ViewBuilder proceed: @escaping () -> Proceed,
        action: @escaping () -> Void,
        disabled: Bool
    ) {
        self.description = description
        self.proceed = proceed
        self.action = action
        self.disabled = disabled
    }

    var body: some View {
        description()
            .padding(.vertical, 15)
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .overlay(alignment: .trailing) {
                Button {
                    action()
                } label: {
                    proceed()
                        .bold()
                        .padding(.horizontal, 20)
                        .padding(.vertical, 15)
                        .frame(width: 141)
                        .ifCondition(!disabled) {
                            $0.background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 0.47, green: 0.69, blue: 1), location: 0.00),
                                        Gradient.Stop(color: Color(red: 0, green: 0.41, blue: 1), location: 1.00),
                                    ],
                                    startPoint: UnitPoint(x: 0, y: 0.5),
                                    endPoint: UnitPoint(x: 1, y: 0.5)
                                )
                            )
                        }
                        .ifCondition(disabled) {
                            $0.background(
                                Color.lightBlue
                            )
                        }
                        .cornerRadius(24)
                }
                .disabled(disabled)
            }
            .font(.customFont(weight: .regular, style: .footnote))
            .foregroundStyle(Color.white)
            .lineLimit(1)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.5), radius: 25, x: 0, y: 4)
    }
}

#Preview {
    VStack {
        FloatingProceedView(description: {
            Text("3 photos selected")
        }, proceed: {
            HStack {
                Text("Next")
                Spacer()
                Icons.arrowDownNormal
                    .foregroundColor(Color.white)
                    .rotationEffect(.degrees(270))
            }
        }, action: {
            //
        }, disabled: false)

        FloatingProceedView(description: {
            Text("You will spend 1 free post")
        }, proceed: {
            HStack {
                Text("Post")
                Spacer()
                Text("->")
            }
        }, action: {
            //
        }, disabled: true)
    }
    .padding(.horizontal, 20)
    .environment(\.colorScheme, .dark)
}
