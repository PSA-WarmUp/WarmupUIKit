//
//  Exercise.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 6/17/25.
//
import Foundation

public struct Exercise: Codable, Identifiable {
    public let id: String
    public let name: String
    public let category: String?
    public let tags: [String]?
    public let equipment: String?
    public let instructions: String?
    public let videoS3Key: String?
    public let isTimeBased: Bool?  // Optional since backend might not send it
    public let difficulty: String?
    public let createdAt: String?
    public let updatedAt: String?

    public let createdBy: String?      // "SYSTEM" or trainer ID
    public let bucketType: String?     // "PREMIUM_EXERCISES", "FREEMIUM_EXERCISES", etc.
    public let media: [MediaItem]?     // Array of media items
    public let aliases: [String]?      // Alternative names
    public let description: String?    // Exercise description
    public let isPublic: Bool?        // Public vs private



    // Media item structure
    public struct MediaItem: Codable {
        public let s3Key: String?
        public let type: String?       // "video", "image", "thumbnail"
        public let fileName: String?
        public let url: String?
        public let fileSizeBytes: Int?
        public let durationSeconds: Int?
        public let thumbnailKey: String?

        public var mediaType: MediaType? {
            guard let type = type else { return nil }
            return MediaType(rawValue: type.lowercased())
        }

        public enum MediaType: String {
            case video = "video"
            case thumbnail = "thumbnail"
            case image = "image"
        }

        public init(
            s3Key: String? = nil,
            type: String? = nil,
            fileName: String? = nil,
            url: String? = nil,
            fileSizeBytes: Int? = nil,
            durationSeconds: Int? = nil,
            thumbnailKey: String? = nil
        ) {
            self.s3Key = s3Key
            self.type = type
            self.fileName = fileName
            self.url = url
            self.fileSizeBytes = fileSizeBytes
            self.durationSeconds = durationSeconds
            self.thumbnailKey = thumbnailKey
        }
    }

    // IMPORTANT: Add this computed property that WorkoutExercise.from() is looking for
    public var isTimeBasedExercise: Bool {
        // First check if backend provides the value
        if let isTimeBased = isTimeBased {
            return isTimeBased
        }
        // Otherwise, default to false (reps-based)
        return false
    }

    // MARK: - Transient Exercise Support

    /// Returns true if this exercise has been persisted to the database
    /// An exercise is considered persisted if it has a valid non-empty ID
    public var isPersisted: Bool {
        return !id.isEmpty && !id.hasPrefix("temp_") && !isTemporaryId(id)
    }

    /// Check if an ID looks like a temporary/transient ID
    private func isTemporaryId(_ id: String) -> Bool {
        // UUIDs from client-side generation are valid but temporary until saved
        // Backend IDs typically follow a different pattern
        // This helps distinguish AI-generated exercises that haven't been matched to the database
        return id.lowercased().hasPrefix("draft_") ||
               id.lowercased().hasPrefix("ai_") ||
               id.lowercased().hasPrefix("new_")
    }

    public var videoURL: URL? {
        if let media = media?.first(where: { $0.mediaType == .video }),
           let urlString = media.url {
            return URL(string: urlString)
        }

        // Fallback to videoS3Key
        if let s3Key = videoS3Key {
            let cloudFrontDomain = "https://dx4slod9x4qks.cloudfront.net"
            return URL(string: "\(cloudFrontDomain)/\(s3Key)")
        }

        return nil
    }

    // Get thumbnail URL with fallback options
    public var thumbnailURL: URL? {
        let cloudFrontDomain = "https://dx4slod9x4qks.cloudfront.net"

        // First try to get thumbnail from media array with direct URL
        if let media = media?.first(where: { $0.mediaType == .thumbnail }),
           let urlString = media.url,
           !urlString.isEmpty {
            return URL(string: urlString)
        }

        // Second: Check if there's a thumbnailKey in video media
        if let videoMedia = media?.first(where: { $0.mediaType == .video }),
           let thumbnailKey = videoMedia.thumbnailKey,
           !thumbnailKey.isEmpty {
            return URL(string: "\(cloudFrontDomain)/\(thumbnailKey)")
        }

        // Third: Check for thumbnail s3Key in media array
        if let thumbnailMedia = media?.first(where: { $0.mediaType == .thumbnail }),
           let s3Key = thumbnailMedia.s3Key,
           !s3Key.isEmpty {
            return URL(string: "\(cloudFrontDomain)/\(s3Key)")
        }

        // No thumbnail available
        return nil
    }

    public init(
        id: String,
        name: String,
        category: String? = nil,
        tags: [String]? = nil,
        equipment: String? = nil,
        instructions: String? = nil,
        videoS3Key: String? = nil,
        isTimeBased: Bool? = false,
        difficulty: String? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil,
        createdBy: String? = nil,
        bucketType: String? = nil,
        media: [MediaItem]? = nil,
        aliases: [String]? = nil,
        description: String? = nil,
        isPublic: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.tags = tags
        self.equipment = equipment
        self.instructions = instructions
        self.videoS3Key = videoS3Key
        self.isTimeBased = isTimeBased
        self.difficulty = difficulty
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdBy = createdBy
        self.bucketType = bucketType
        self.media = media
        self.aliases = aliases
        self.description = description
        self.isPublic = isPublic
    }
}
