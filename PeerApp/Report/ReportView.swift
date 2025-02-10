//
//  ReportView.swift
//  PeerApp
//
//  Created by Артем Васин on 07.01.25.
//

import SwiftUI
import DesignSystem
import Models
import Networking
import GQLOperationsUser

struct ReportView: View {
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var theme: Theme
    
    @State private var isSendingReport: Bool = false
    
    let post: Post
    
    var body: some View {
        NavigationStack {
            Form {
                
            }
            .navigationTitle("Report Post")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(theme.secondaryBackgroundColor)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isSendingReport = true
                        Task {
                            do {
                                let _ = try await GQLClient.shared.mutate(mutation: ReportPostMutation(postid: post.id)) // TODO: Handle error
                                dismiss()
                                isSendingReport = false
                            } catch {
                                isSendingReport = false
                            }
                        }
                    } label: {
                        if isSendingReport {
                            ProgressView()
                        } else {
                            Text("Send")
                        }
                    }
                }
                
                CancelToolbarItem()
            }
        }
    }
}
