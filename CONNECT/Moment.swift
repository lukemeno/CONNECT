//
//  Moment.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftData

enum MomentPrivacy: String, CaseIterable, Codable {
    case publicMoment = "public"
    case friends = "friends"
    case privateMoment = "private"
    
    var displayName: String {
        switch self {
        case .publicMoment: return "Public"
        case .friends: return "Friends"
        case .privateMoment: return "Private"
        }
    }
    
    var systemImage: String {
        switch self {
        case .publicMoment: return "globe"
        case .friends: return "person.2"
        case .privateMoment: return "lock"
        }
    }
}

enum MediaType: String, CaseIterable, Codable {
    case none = "none"
    case image = "image"
    case video = "video"
    case audio = "audio"
    
    var displayName: String {
        switch self {
        case .none: return "Text"
        case .image: return "Photo"
        case .video: return "Video"
        case .audio: return "Audio"
        }
    }
}

enum ModerationStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case flagged = "flagged"
}

@Model
final class Moment {
    @Attribute(.unique) var id: UUID
    var content: String
    var mediaURLs: [String]
    var mediaType: MediaType
    var privacy: MomentPrivacy
    var hashtags: [String]
    var feeling: String?
    var activity: String?
    var moderationStatus: ModerationStatus
    var isEdited: Bool
    var editedAt: Date?
    var createdAt: Date
    var likesCount: Int
    var commentsCount: Int
    var sharesCount: Int
    
    // Relationships - Simplified to avoid circular references
    @Relationship(deleteRule: .nullify)
    var author: User?
    
    @Relationship(deleteRule: .cascade)
    var comments: [Comment] = []
    
    @Relationship(deleteRule: .cascade)
    var reactions: [Reaction] = []
    
    @Relationship(deleteRule: .nullify)
    var location: Location?
    
    init(
        content: String,
        author: User,
        mediaURLs: [String] = [],
        mediaType: MediaType = .none,
        privacy: MomentPrivacy = .friends,
        hashtags: [String] = [],
        feeling: String? = nil,
        activity: String? = nil,
        location: Location? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.author = author
        self.mediaURLs = mediaURLs
        self.mediaType = mediaType
        self.privacy = privacy
        self.hashtags = hashtags
        self.feeling = feeling
        self.activity = activity
        self.location = location
        self.moderationStatus = .approved
        self.isEdited = false
        self.createdAt = Date()
        self.likesCount = 0
        self.commentsCount = 0
        self.sharesCount = 0
    }
}

// MARK: - Moment Extensions
extension Moment {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var hasMedia: Bool {
        !mediaURLs.isEmpty && mediaType != .none
    }
    
    var displayContent: String {
        if content.isEmpty && hasMedia {
            return "Shared a \(mediaType.displayName.lowercased())"
        }
        return content
    }
    
    func incrementLikes() {
        likesCount += 1
    }
    
    func decrementLikes() {
        likesCount = max(0, likesCount - 1)
    }
    
    func incrementComments() {
        commentsCount += 1
    }
    
    func decrementComments() {
        commentsCount = max(0, commentsCount - 1)
    }
} 