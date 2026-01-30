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
        public let user: UserConstants
        public let dailyFree: DailyFreeData
        public let tokenomics: Tokenomics
        public let minting: MintingData

        public enum CodingKeys: String, CodingKey {
            case post = "POST"
            case comment = "COMMENT"
            case user = "USER"
            case dailyFree = "DAILY_FREE"
            case tokenomics = "TOKENOMICS"
            case minting = "MINTING"
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

    public struct UserConstants: Codable {
        public let username: Username
        public let password: Password
        public let biography: LengthConstraints

        public enum CodingKeys: String, CodingKey {
            case username = "USERNAME"
            case password = "PASSWORD"
            case biography = "BIOGRAPHY"
        }

        public struct Password: Codable {
            public let minLength: Int
            public let maxLength: Int
            public let pattern: String

            public enum CodingKeys: String, CodingKey {
                case minLength = "MIN_LENGTH"
                case maxLength = "MAX_LENGTH"
                case pattern = "PATTERN"
            }
        }

        public struct Username: Codable {
            public let minLength: Int
            public let maxLength: Int
            public let pattern: String

            public enum CodingKeys: String, CodingKey {
                case minLength = "MIN_LENGTH"
                case maxLength = "MAX_LENGTH"
                case pattern = "PATTERN"
            }
        }
    }

    public struct DailyFreeData: Codable {
        public let dailyFreeActions: DailyFreeActions

        public enum CodingKeys: String, CodingKey {
            case dailyFreeActions = "DAILY_FREE_ACTIONS"
        }

        public struct DailyFreeActions: Codable {
            public let post: Int
            public let like: Int
            public let comment: Int
            public let dislike: Int
        }
    }

    public struct Tokenomics: Codable {
        public let actionTokenPrices: ActionTokenPrices
        public let actionGemsReturn: ActionGemsReturn
        public let fees: Fees

        public enum CodingKeys: String, CodingKey {
            case actionTokenPrices = "ACTION_TOKEN_PRICES"
            case actionGemsReturn = "ACTION_GEMS_RETURNS"
            case fees = "FEES"
        }

        public struct ActionTokenPrices: Codable {
            public let post: Double
            public let like: Double
            public let comment: Double
            public let dislike: Double
            public let advertisementBasic: Double
            public let advertisementPinned: Double
        }

        public struct ActionGemsReturn: Codable {
            public let view: Double
            public let like: Double
            public let comment: Double
            public let dislike: Double
        }

        public struct Fees: Codable {
            public let invitation: Double
            public let peer: Double
            public let burn: Double

            public enum CodingKeys: String, CodingKey {
                case invitation = "INVITATION"
                case peer = "PEER"
                case burn = "BURN"
            }
        }
    }

    public struct MintingData: Codable {
        public let dailyNumberTokens: Int

        public enum CodingKeys: String, CodingKey {
            case dailyNumberTokens = "DAILY_NUMBER_TOKEN"
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

extension ConstantsConfig: Equatable {
    public static func == (lhs: ConstantsConfig, rhs: ConstantsConfig) -> Bool {
        return lhs.hash == rhs.hash
    }
}
