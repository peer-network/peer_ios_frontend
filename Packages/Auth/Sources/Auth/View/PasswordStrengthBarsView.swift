//
//  PasswordStrengthBarsView.swift
//  Auth
//
//  Created by Артем Васин on 27.01.25.
//

import SwiftUI

struct PasswordStrengthBarsView: View {
    let strength: AuthViewModel.PasswordStrength
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0..<4, id: \.self) { bar in
                RoundedRectangle(cornerRadius: 29)
                    .frame(width: 36, height: 2)
                    .foregroundStyle(bar < barsAmount ? barsColor : Color.passwordBarsEmpty)
                    .padding(.trailing, 3)
            }
            .layoutPriority(1)
            
            Spacer()
                .frame(minWidth: 7)
            
            Text(strength.rawValue)
                .font(.customFont(weight: .regular, size: .footnote))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.white.opacity(0.6))
                .layoutPriority(1)
        }
    }
    
    private var barsAmount: Int {
        switch strength {
            case .empty:
                0
            case .tooWeak:
                1
            case .notStrongEnough:
                2
            case .good:
                3
            case .excellent:
                4
        }
    }
    
    private var barsColor: Color {
        switch strength {
            case .empty:
                Color.passwordBarsEmpty
            case .tooWeak:
                Color.passwordBarsRed
            case .notStrongEnough:
                Color.passwordBarsRed
            case .good:
                Color.passwordBarsYellow
            case .excellent:
                Color.passwordBarsGreen
        }
    }
}

#Preview {
    VStack {
        PasswordStrengthBarsView(strength: .tooWeak)
        PasswordStrengthBarsView(strength: .notStrongEnough)
        PasswordStrengthBarsView(strength: .good)
        PasswordStrengthBarsView(strength: .excellent)
    }
    .background(Color.black)
}
