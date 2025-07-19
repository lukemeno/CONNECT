//
//  Reaction.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftData

enum ReactionType: String, CaseIterable, Codable {
    case like = "like"
    case love = "love"
    case laugh = "laugh"
    case wow = "wow"
    case sad = "sad"
    case angry = "angry"
    
    var emoji: String {
        switch self {
        case .like: return "👍"
        case .love: return "❤️"
        case .laugh: return "😂"
        case .wow: return "😮"
        case .sad: return "😢"
        case .angry: return "😡"
        }
    }
    
    var displayName: String {
        switch self {
        case .like: return "Like"
        case .love: return "Love"
        case .laugh: return "Laugh"
        case .wow: return "Wow"
        case .sad: return "Sad"
        case .angry: return "Angry"
        }
    }
}

@Model
final class Reaction {
    @Attribute(.unique) var id: UUID
    var type: ReactionType
    var createdAt: Date
    
    // Relationships - Simplified to avoid circular references
    @Relationship(deleteRule: .nullify)
    var user: User?
    
    @Relationship(deleteRule: .nullify)
    var moment: Moment?
    
    @Relationship(deleteRule: .nullify)
    var comment: Comment?
    
    init(
        type: ReactionType,
        user: User,
        moment: Moment? = nil,
        comment: Comment? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.user = user
        self.moment = moment
        self.comment = comment
        self.createdAt = Date()
    }
}

// MARK: - Reaction Extensions
extension Reaction {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
} 