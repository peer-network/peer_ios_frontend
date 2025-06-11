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
    
    func makeUIView(context: Context) -> UICollectionView {
        let layout = CollectionViewChatLayout()
        layout.settings.interItemSpacing = 4
        layout.settings.interSectionSpacing = 4
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 4, left: 2, bottom: 4, right: 2)
        
        collectionView.register(ReliableChatCell.self, forCellWithReuseIdentifier: "ReliableChatCell")
        collectionView.dataSource = context.coordinator
        collectionView.delegate = context.coordinator
        context.coordinator.collectionView = collectionView
        
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.messages = messages
        uiView.reloadData()
        
        DispatchQueue.main.async {
            let sections = uiView.numberOfSections
            guard sections > 0 else { return }
            
            let items = uiView.numberOfItems(inSection: sections - 1)
            guard items > 0 else { return }
            
            let indexPath = IndexPath(item: items - 1, section: sections - 1)
            if indexPath.item >= 0 && indexPath.section >= 0 {
                uiView.scrollToItem(at: indexPath, at: .bottom, animated: true)
            }
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
