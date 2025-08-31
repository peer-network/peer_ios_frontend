//
//  MediaItem.swift
//  Models
//
//  Created by Artem Vasin on 20.03.25.
//

import Foundation

public struct MediaItem: Codable, Hashable {
    public let path: String
    public let options: MediaOptions?

    public var size: String? {
        switch options {
            case .image(let imageOptions): return imageOptions.size
            case .text(let textOptions): return textOptions.size
            case .audio(let audioOptions): return audioOptions.size
            case .video(let videoOptions): return videoOptions.size
            default: return nil
        }
    }

    public var resolution: String? {
        switch options {
            case .image(let imageOptions): return imageOptions.resolution
            case .video(let videoOptions): return videoOptions.resolution
            default: return nil
        }
    }

    public var duration: TimeInterval? {
        switch options {
            case .audio(let audioOptions):
                return timeInterval(from: audioOptions.duration)
            case .video(let videoOptions):
                guard let duration = videoOptions.duration else { return nil }
                return timeInterval(from: duration)
            default:
                return nil
        }
    }

    public var ratio: String? {
        switch options {
            case .video(let videoOptions): return videoOptions.ratio
            default: return nil
        }
    }

    private func timeInterval(from timeString: String) -> TimeInterval? {
        let components = timeString.split(separator: ":").compactMap { Double($0) }
        guard components.count == 3 else { return nil }

        let hours = components[0]
        let minutes = components[1]
        let seconds = components[2]

        return (hours * 3600) + (minutes * 60) + seconds
    }
}

extension MediaItem {
    public var aspectRatio: CGFloat {
        // Default to square if no resolution
        guard let resolution = self.resolution else { return 1.0 }

        let components = resolution.components(separatedBy: "x")
        guard components.count == 2,
              let width = Double(components[0]),
              let height = Double(components[1])
        else {
            return 1.0 // Default to square if resolution format is invalid
        }

        // If height is greater than width, use 5:4 ratio
        return height > width ? 5/4 : 1.0
    }

    public var videoAspectRatio: CGFloat {
        // Default to square if no resolution
        guard let resolution = self.ratio else { return 1.0 }

        let components = resolution.components(separatedBy: ":")
        guard components.count == 2,
              let width = Double(components[0]),
              let height = Double(components[1]),
              height != 0 // Prevent division by zero
        else {
            return 1.0 // Default to square if resolution format is invalid
        }

        return width / height
    }
}

// MARK: - MediaOptions

public enum MediaOptions: Codable {
    case image(ImageOptions)
    case text(TextOptions)
    case audio(AudioOptions)
    case video(VideoOptions)

    private enum CodingKeys: String, CodingKey {
        case size, resolution, duration, ratio
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let resolution = try? container.decode(String.self, forKey: .resolution) {
            if let ratio = try? container.decode(String.self, forKey: .ratio) {
                self = .video(VideoOptions(
                    size: try container.decode(String.self, forKey: .size),
                    duration: try? container.decode(String.self, forKey: .duration),
                    ratio: ratio,
                    resolution: resolution
                ))
            } else {
                self = .image(ImageOptions(
                    size: try container.decode(String.self, forKey: .size),
                    resolution: resolution
                ))
            }
        } else if let duration = try? container.decode(String.self, forKey: .duration) {
            self = .audio(AudioOptions(
                size: try container.decode(String.self, forKey: .size),
                duration: duration
            ))
        } else {
            self = .text(TextOptions(
                size: try container.decode(String.self, forKey: .size)
            ))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .image(let options):
                try container.encode(options.size, forKey: .size)
                try container.encode(options.resolution, forKey: .resolution)
            case .text(let options):
                try container.encode(options.size, forKey: .size)
            case .audio(let options):
                try container.encode(options.size, forKey: .size)
                try container.encode(options.duration, forKey: .duration)
            case .video(let options):
                try container.encode(options.size, forKey: .size)
                try container.encodeIfPresent(options.duration, forKey: .duration)
                try container.encode(options.ratio, forKey: .ratio)
                try container.encode(options.resolution, forKey: .resolution)
        }
    }
}

extension MediaOptions: Hashable {
    public static func == (lhs: MediaOptions, rhs: MediaOptions) -> Bool {
        switch (lhs, rhs) {
            case (.image(let lhsOptions), .image(let rhsOptions)):
                return lhsOptions == rhsOptions
            case (.text(let lhsOptions), .text(let rhsOptions)):
                return lhsOptions == rhsOptions
            case (.audio(let lhsOptions), .audio(let rhsOptions)):
                return lhsOptions == rhsOptions
            case (.video(let lhsOptions), .video(let rhsOptions)):
                return lhsOptions == rhsOptions
            default:
                return false
        }
    }
}

// Individual Option Structs
public struct ImageOptions: Codable, Hashable {
    public let size: String
    public let resolution: String
}

public struct TextOptions: Codable, Hashable {
    public let size: String
}

public struct AudioOptions: Codable, Hashable {
    public let size: String
    public let duration: String
}

public struct VideoOptions: Codable, Hashable {
    public let size: String
    public let duration: String?
    public let ratio: String
    public let resolution: String
}
