//
//  Community.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftData

enum CommunityType: String, CaseIterable, Codable {
    case `public` = "public"
    case `private` = "private"
    case secret = "secret"
    
    var displayName: String {
        switch self {
        case .public: return "Public"
        case .private: return "Private"
        case .secret: return "Secret"
        }
    }
    
    var systemImage: String {
        switch self {
        case .public: return "globe"
        case .private: return "lock.shield"
        case .secret: return "eye.slash"
        }
    }
}

@Model
final class Community {
    @Attribute(.unique) var id: UUID
    var name: String
    var communityDescription: String
    var imageURL: String?
    var type: CommunityType
    var createdAt: Date
    var membersCount: Int
    var isVerified: Bool
    var rules: [String]
    var tags: [String]
    
    // Relationships - Simplified to avoid circular references
    @Relationship(deleteRule: .nullify)
    var members: [User] = []
    
    @Relationship(deleteRule: .nullify)
    var admins: [User] = []
    
    @Relationship(deleteRule: .nullify)
    var creator: User?
    
    @Relationship(deleteRule: .cascade)
    var events: [Event] = []
    
    init(
        name: String,
        description: String,
        creator: User,
        type: CommunityType = .public,
        imageURL: String? = nil,
        rules: [String] = [],
        tags: [String] = []
    ) {
        self.id = UUID()
        self.name = name
        self.communityDescription = description
        self.creator = creator
        self.type = type
        self.imageURL = imageURL
        self.rules = rules
        self.tags = tags
        self.createdAt = Date()
        self.membersCount = 1
        self.isVerified = false
        
        // Creator is automatically a member and admin
        self.members.append(creator)
        self.admins.append(creator)
    }
}

// MARK: - Community Extensions
extension Community {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
    
    func addMember(_ user: User) {
        if !members.contains(where: { $0.id == user.id }) {
            members.append(user)
            membersCount += 1
        }
    }
    
    func removeMember(_ user: User) {
        members.removeAll { $0.id == user.id }
        admins.removeAll { $0.id == user.id }
        membersCount = max(0, membersCount - 1)
    }
    
    func makeAdmin(_ user: User) {
        if members.contains(where: { $0.id == user.id }) && !admins.contains(where: { $0.id == user.id }) {
            admins.append(user)
        }
    }
    
    func isAdmin(_ user: User) -> Bool {
        admins.contains { $0.id == user.id }
    }
    
    func isMember(_ user: User) -> Bool {
        members.contains { $0.id == user.id }
    }
} 