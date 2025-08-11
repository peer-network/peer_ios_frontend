//
//  ForcedUpdateView.swift
//  DesignSystem
//
//  Created by Artem Vasin on 10.04.25.
//

import SwiftUI

public struct ForcedUpdateView: View {
    private let message: String
    private let storeURL: URL?

    public init(message: String, storeURL: URL?) {
        self.message = message
        self.storeURL = storeURL
    }

    public var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)

                Text("Update Required")
                    .font(.title)
                    .bold()

                Text(message)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                if let storeURL = storeURL {
                    Button(action: {
                        UIApplication.shared.open(storeURL)
                    }) {
                        Text("Update Now")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
    }
}

#Preview {
    ForcedUpdateView(message: "You need to update your app to continue using it.", storeURL: URL(string: "apple.com")!)
}
