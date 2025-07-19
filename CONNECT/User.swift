//
//  User.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class User {
    @Attribute(.unique) var id: UUID
    var username: String
    var displayName: String
    var email: String
    var profilePictureURL: String?
    var bio: String
    var interests: [String]
    var isPrivateAccount: Bool
    var isVerified: Bool
    var dateJoined: Date
    var lastActiveDate: Date
    
    // GDPR Compliance
    var hasAcceptedTerms: Bool
    var hasAcceptedPrivacyPolicy: Bool
    var gdprConsentDate: Date?
    var analyticsConsent: Bool
    var marketingConsent: Bool
    
    // Privacy Settings
    var allowFriendRequests: Bool
    var allowDiscovery: Bool
    var showOnlineStatus: Bool
    var allowLocationSharing: Bool
    
    // Stats
    var followersCount: Int
    var followingCount: Int
    var momentsCount: Int
    
    // Relationships - Remove inverse to avoid circular references
    @Relationship(deleteRule: .cascade)
    var moments: [Moment] = []
    
    @Relationship(deleteRule: .cascade)
    var comments: [Comment] = []
    
    @Relationship(deleteRule: .cascade)
    var reactions: [Reaction] = []
    
    @Relationship(deleteRule: .cascade)
    var sentFriendRequests: [FriendRequest] = []
    
    @Relationship(deleteRule: .cascade)
    var receivedFriendRequests: [FriendRequest] = []
    
    @Relationship(deleteRule: .nullify)
    var communities: [Community] = []
    
    @Relationship(deleteRule: .nullify)
    var events: [Event] = []
    
    // Self-referencing many-to-many for friends
    @Relationship(deleteRule: .nullify)
    var friends: [User] = []
    
    @Relationship(deleteRule: .nullify)
    var following: [User] = []
    
    init(
        username: String,
        displayName: String,
        email: String,
        profilePictureURL: String? = nil,
        bio: String = "",
        interests: [String] = []
    ) {
        self.id = UUID()
        self.username = username
        self.displayName = displayName
        self.email = email
        self.profilePictureURL = profilePictureURL
        self.bio = bio
        self.interests = interests
        self.isPrivateAccount = false
        self.isVerified = false
        self.dateJoined = Date()
        self.lastActiveDate = Date()
        
        // GDPR defaults
        self.hasAcceptedTerms = false
        self.hasAcceptedPrivacyPolicy = false
        self.analyticsConsent = false
        self.marketingConsent = false
        
        // Privacy defaults
        self.allowFriendRequests = true
        self.allowDiscovery = true
        self.showOnlineStatus = true
        self.allowLocationSharing = false
        
        // Stats
        self.followersCount = 0
        self.followingCount = 0
        self.momentsCount = 0
    }
}

// MARK: - User Extensions
extension User {
    var isOnline: Bool {
        Date().timeIntervalSince(lastActiveDate) < 300 // 5 minutes
    }
    
    var profileImage: Image {
        // This would be replaced with actual image loading logic
        Image(systemName: "person.circle.fill")
    }
    
    func updateLastActive() {
        lastActiveDate = Date()
    }
    
    func acceptGDPRTerms() {
        hasAcceptedTerms = true
        hasAcceptedPrivacyPolicy = true
        gdprConsentDate = Date()
    }
}
