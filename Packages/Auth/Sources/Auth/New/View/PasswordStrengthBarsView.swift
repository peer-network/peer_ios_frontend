//
//  PasswordStrengthBarsView.swift
//  Auth
//
//  Created by Артем Васин on 27.01.25.
//

import SwiftUI
import DesignSystem

struct PasswordStrengthBarsView: View {
    let strength: PasswordStrength
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(0..<4, id: \.self) { bar in
                RoundedRectangle(cornerRadius: 29)
                    .frame(width: 36, height: 2)
                    .foregroundStyle(bar < barsAmount ? barsColor : Colors.passwordBarsEmpty)
                    .padding(.trailing, 3)
            }
            .layoutPriority(1)
            
            Spacer()
                .frame(minWidth: 7)
            
            Text(strength.rawValue)
                .appFont(.smallLabelRegular)
                .foregroundStyle(Colors.whiteSecondary)
                .multilineTextAlignment(.center)
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
                Colors.passwordBarsEmpty
            case .tooWeak:
                Colors.passwordBarsRed
            case .notStrongEnough:
                Colors.passwordBarsRed
            case .good:
                Colors.passwordBarsYellow
            case .excellent:
                Colors.passwordBarsGreen
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
