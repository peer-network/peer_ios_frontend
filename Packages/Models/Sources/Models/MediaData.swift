//
//  MediaData.swift
//  Models
//
//  Created by Артем Васин on 10.01.25.
//

import Foundation

public struct MediaData: Identifiable, Hashable {
    public let id: URL
    public let url: URL
    public let type: Post.ContentType
    
    public init?(url: URL?, type: Post.ContentType) {
        guard let url else { return nil }
        
        self.id = url
        self.url = url
        self.type = type
    }
}
