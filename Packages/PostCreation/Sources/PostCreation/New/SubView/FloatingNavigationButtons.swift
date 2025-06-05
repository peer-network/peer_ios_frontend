//
//  FloatingNavigationButtons.swift
//  PostCreation
//
//  Created by Artem Vasin on 16.05.25.
//

import SwiftUI
import DesignSystem

struct FloatingNavigationButtons: View {
    let clearAction: () -> Void
    let postAction: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button {
                clearAction()
            } label: {
                Text("Clear")
            }
            .buttonStyle(StrokeButtonStyle())

            Button {
                postAction()
            } label: {
                Text("Post")
            }
            .buttonStyle(TargetButtonStyle())
        }
    }

    

//    Button {
//        router.navigate(to: .changePassword)
//    } label: {
//        Text("Change password")
//            .font(.customFont(weight: .regular, style: .footnote))
//            .foregroundStyle(Colors.blackDark)
//            .padding(20)
//            .frame(maxWidth: .infinity)
//            .background {
//                RoundedRectangle(cornerRadius: 24)
//                    .foregroundStyle(Colors.whitePrimary)
//            }
//    }
//
//    Button {
//        audioManager.stop()
//        analytics.track(AuthEvent.logout)
//        analytics.resetUserID()
//        authManager.logout()
//    } label: {
//        Text("Logout")
//            .padding(20)
//            .foregroundStyle(Colors.redAccent)
//            .font(.customFont(weight: .regular, style: .footnote))
//            .frame(maxWidth: .infinity)
//            .overlay {
//                RoundedRectangle(cornerRadius: 24)
//                    .strokeBorder(Colors.redAccent, lineWidth: 1)
//            }
//    }
}
