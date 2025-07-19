//
//  FriendRequest.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftData

enum FriendRequestStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case declined = "declined"
    case blocked = "blocked"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .declined: return "Declined"
        case .blocked: return "Blocked"
        }
    }
}

@Model
final class FriendRequest {
    @Attribute(.unique) var id: UUID
    var status: FriendRequestStatus
    var message: String?
    var sentAt: Date
    var respondedAt: Date?
    
    // Relationships - Simplified to avoid circular references
    @Relationship(deleteRule: .nullify)
    var sender: User?
    
    @Relationship(deleteRule: .nullify)
    var receiver: User?
    
    init(
        sender: User,
        receiver: User,
        message: String? = nil
    ) {
        self.id = UUID()
        self.sender = sender
        self.receiver = receiver
        self.message = message
        self.status = .pending
        self.sentAt = Date()
    }
}

// MARK: - FriendRequest Extensions
extension FriendRequest {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: sentAt, relativeTo: Date())
    }
    
    func accept() {
        status = .accepted
        respondedAt = Date()
        
        // Add each user to the other's friends list (check for duplicates)
        if let sender = sender, let receiver = receiver {
            if !sender.friends.contains(where: { $0.id == receiver.id }) {
                sender.friends.append(receiver)
                sender.followingCount += 1
            }
            if !receiver.friends.contains(where: { $0.id == sender.id }) {
                receiver.friends.append(sender)
                receiver.followersCount += 1
            }
        }
    }
    
    func decline() {
        status = .declined
        respondedAt = Date()
    }
    
    func block() {
        status = .blocked
        respondedAt = Date()
    }
}  