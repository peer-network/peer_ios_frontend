//
//  ChatLayoutView.swift
//  Chat
//
//  Created by Siva kumar Aketi on 04/06/25.
//

import SwiftUI
import ChatLayout

struct ChatLayoutView: UIViewRepresentable {
    let messages: [Message1]
    var scrollToLatest: Bool
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = CollectionViewChatLayout()
        layout.settings.interItemSpacing = 4
        layout.settings.interSectionSpacing = 4
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 4, left: 2, bottom: 40, right: 2)
        
        collectionView.register(ReliableChatCell.self, forCellWithReuseIdentifier: "ReliableChatCell")
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        context.coordinator.collectionView = collectionView
        
        // Ensure layout is completed before scrolling
        DispatchQueue.main.async {
            context.coordinator.scrollToBottom(animated: false)
        }

        return collectionView
    }

        
    func updateUIView(_ uiView: UICollectionView, context: Context) {
            let previousCount = context.coordinator.messages.count
            context.coordinator.messages = messages
        if scrollToLatest {
                context.coordinator.scrollToBottom(animated: true)
            }

            guard messages.count != previousCount else { return }

            let newItemsCount = messages.count - previousCount
            if newItemsCount > 0 {
                let newIndexPaths = (previousCount..<messages.count).map { IndexPath(item: $0, section: 0) }

                uiView.performBatchUpdates {
                    uiView.insertItems(at: newIndexPaths)
                } completion: { _ in
                    if let last = newIndexPaths.last {
                        uiView.scrollToItem(at: last, at: .bottom, animated: true)
                    }
                }
            } else {
                uiView.reloadData()
            }
        }



    
    func makeCoordinator() -> Coordinator {
        Coordinator(messages: messages)
    }
    
    class Coordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegate {
        var messages: [Message1]
        weak var collectionView: UICollectionView?

        init(messages: [Message1]) {
            self.messages = messages
            super.init()
            addKeyboardObservers()
        }

        deinit {
            removeKeyboardObservers()
        }

        func addKeyboardObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }

        func removeKeyboardObservers() {
            NotificationCenter.default.removeObserver(self)
        }

        @objc func keyboardWillShow(_ notification: Notification) {
            guard let collectionView = collectionView,
                  let userInfo = notification.userInfo,
                  let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let window = collectionView.window else { return }
            
            // Convert keyboard frame to collectionView coordinates
            let convertedFrame = collectionView.convert(keyboardFrame, from: window)
            let intersection = collectionView.bounds.intersection(convertedFrame)
            
            // Calculate the overlap
            let bottomInset = intersection.height
            
            collectionView.contentInset.bottom = bottomInset + 60 
            collectionView.scrollIndicatorInsets.bottom = bottomInset + 60
            
            // Scroll to bottom if needed
            scrollToBottom()
        }


        @objc func keyboardWillHide(_ notification: Notification) {
            guard let collectionView = collectionView else { return }
            collectionView.contentInset.bottom = 4
            collectionView.scrollIndicatorInsets.bottom = 4
        }

        func scrollToBottom(animated: Bool = true, extraPadding: CGFloat = 60) {
            guard let collectionView = collectionView, messages.count > 0 else { return }
            
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            
            // Ensure layout pass is complete before scrolling
            DispatchQueue.main.async {
                collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
            }
        }

        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            messages.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReliableChatCell", for: indexPath) as! ReliableChatCell
            let message = messages[indexPath.item]
            cell.configure(with: message)
            return cell
        }
    }
}
