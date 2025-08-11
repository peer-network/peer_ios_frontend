//
//  ConstantsConfig.swift
//  Environment
//
//  Created by Artem Vasin on 17.06.25.
//

import Foundation

public struct ConstantsConfig: Codable {
    public let createdAt: TimeInterval
    public let hash: String
    public let name: String
    public let data: ConstantsData

    public struct ConstantsData: Codable {
        public let post: PostConstants
        public let comment: CommentConstants

        public enum CodingKeys: String, CodingKey {
            case post = "POST"
            case comment = "COMMENT"
        }
    }

    public struct PostConstants: Codable {
        public let title: LengthConstraints
        public let mediaDescription: LengthConstraints

        public enum CodingKeys: String, CodingKey {
            case title = "TITLE"
            case mediaDescription = "MEDIADESCRIPTION"
        }
    }

    public struct CommentConstants: Codable {
        public let content: LengthConstraints

        public enum CodingKeys: String, CodingKey {
            case content = "CONTENT"
        }
    }

    public struct LengthConstraints: Codable {
        public let minLength: Int
        public let maxLength: Int

        public enum CodingKeys: String, CodingKey {
            case minLength = "MIN_LENGTH"
            case maxLength = "MAX_LENGTH"
        }
    }
}
