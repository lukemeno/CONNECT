//
//  Comment.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftData

@Model
final class Comment {
    @Attribute(.unique) var id: UUID
    var content: String
    var createdAt: Date
    var isEdited: Bool
    var editedAt: Date?
    var likesCount: Int
    var repliesCount: Int
    
    // Relationships - Simplified to avoid circular references
    @Relationship(deleteRule: .nullify)
    var author: User?
    
    @Relationship(deleteRule: .nullify)
    var moment: Moment?
    
    @Relationship(deleteRule: .nullify)
    var parentComment: Comment?
    
    @Relationship(deleteRule: .cascade)
    var replies: [Comment] = []
    
    @Relationship(deleteRule: .cascade)
    var reactions: [Reaction] = []
    
    init(
        content: String,
        author: User,
        moment: Moment? = nil,
        parentComment: Comment? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.author = author
        self.moment = moment
        self.parentComment = parentComment
        self.createdAt = Date()
        self.isEdited = false
        self.likesCount = 0
        self.repliesCount = 0
    }
}

// MARK: - Comment Extensions
extension Comment {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    var isReply: Bool {
        parentComment != nil
    }
    
    var depth: Int {
        var count = 0
        var current = parentComment
        while current != nil {
            count += 1
            current = current?.parentComment
        }
        return count
    }
    
    func incrementLikes() {
        likesCount += 1
    }
    
    func decrementLikes() {
        likesCount = max(0, likesCount - 1)
    }
    
    func incrementReplies() {
        repliesCount += 1
        parentComment?.incrementReplies()
    }
    
    func decrementReplies() {
        repliesCount = max(0, repliesCount - 1)
        parentComment?.decrementReplies()
    }
} 