//
//  UserDiscoveryService.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftUI
import SwiftData
import CoreLocation

@MainActor
class UserDiscoveryService: ObservableObject {
    @Published var isLoading = false
    @Published var discoveryError: String?
    @Published var suggestedUsers: [User] = []
    
    enum DiscoveryCategory: String, CaseIterable {
        case nearby = "nearby"
        case interests = "interests"
        case popular = "popular"
        case newUsers = "new"
        case all = "all"
        
        var displayName: String {
            switch self {
            case .nearby: return "Nearby"
            case .interests: return "Similar Interests"
            case .popular: return "Popular"
            case .newUsers: return "New Users"
            case .all: return "All"
            }
        }
        
        var systemImage: String {
            switch self {
            case .nearby: return "location"
            case .interests: return "heart"
            case .popular: return "star"
            case .newUsers: return "sparkles"
            case .all: return "person.3"
            }
        }
    }
    
    func discoverUsers(
        for currentUser: User,
        category: DiscoveryCategory = .all,
        location: CLLocation? = nil,
        modelContext: ModelContext,
        limit: Int = 20
    ) async -> [User] {
        isLoading = true
        discoveryError = nil
        
        do {
            // Get all users except current user and existing friends
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate { user in
                    user.id != currentUser.id && user.allowDiscovery
                }
            )
            
            let allUsers = try modelContext.fetch(descriptor)
            
            // Filter out existing friends
            let nonFriends = allUsers.filter { user in
                !currentUser.friends.contains(where: { $0.id == user.id })
            }
            
            // Apply category-specific filtering and scoring
            let filteredUsers = await applyDiscoveryFilter(
                users: nonFriends,
                category: category,
                currentUser: currentUser,
                userLocation: location
            )
            
            let result = Array(filteredUsers.prefix(limit))
            
            await MainActor.run {
                self.suggestedUsers = result
                self.isLoading = false
            }
            
            return result
            
        } catch {
            discoveryError = "Failed to discover users: \(error.localizedDescription)"
            isLoading = false
            return []
        }
    }
    
    private func applyDiscoveryFilter(
        users: [User],
        category: DiscoveryCategory,
        currentUser: User,
        userLocation: CLLocation?
    ) async -> [User] {
        switch category {
        case .nearby:
            return findNearbyUsers(users: users, location: userLocation)
        case .interests:
            return findUsersBySimilarInterests(users: users, currentUser: currentUser)
        case .popular:
            return findPopularUsers(users: users)
        case .newUsers:
            return findNewUsers(users: users)
        case .all:
            return scoreAllUsers(users: users, currentUser: currentUser, location: userLocation)
        }
    }
    
    private func findNearbyUsers(users: [User], location: CLLocation?) -> [User] {
        // In a real app, you'd compare user locations
        // For demo, return a random subset
        return Array(users.shuffled().prefix(10))
    }
    
    private func findUsersBySimilarInterests(users: [User], currentUser: User) -> [User] {
        let currentUserInterests = Set(currentUser.interests)
        
        let scoredUsers = users.map { user -> (user: User, score: Int) in
            let commonInterests = Set(user.interests).intersection(currentUserInterests)
            return (user: user, score: commonInterests.count)
        }
        
        return scoredUsers
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }
            .map { $0.user }
    }
    
    private func findPopularUsers(users: [User]) -> [User] {
        return users.sorted { user1, user2 in
            let score1 = user1.followersCount + user1.momentsCount
            let score2 = user2.followersCount + user2.momentsCount
            return score1 > score2
        }
    }
    
    private func findNewUsers(users: [User]) -> [User] {
        let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return users
            .filter { $0.dateJoined >= oneWeekAgo }
            .sorted { $0.dateJoined > $1.dateJoined }
    }
    
    private func scoreAllUsers(users: [User], currentUser: User, location: CLLocation?) -> [User] {
        let currentUserInterests = Set(currentUser.interests)
        
        let scoredUsers = users.map { user -> (user: User, score: Double) in
            var score = 0.0
            
            // Interest similarity
            let commonInterests = Set(user.interests).intersection(currentUserInterests)
            score += Double(commonInterests.count) * 20
            
            // Popularity factor
            score += Double(user.followersCount) * 0.1
            score += Double(user.momentsCount) * 0.5
            
            // Activity recency
            let daysSinceActive = Date().timeIntervalSince(user.lastActiveDate) / (24 * 3600)
            score += max(0, 10 - daysSinceActive)
            
            // New user bonus
            let daysSinceJoined = Date().timeIntervalSince(user.dateJoined) / (24 * 3600)
            if daysSinceJoined < 7 {
                score += 5 // Boost new users
            }
            
            // Verification bonus
            if user.isVerified {
                score += 10
            }
            
            return (user: user, score: score)
        }
        
        return scoredUsers
            .sorted { $0.score > $1.score }
            .map { $0.user }
    }
    
    // MARK: - Search Users
    func searchUsers(
        query: String,
        currentUser: User,
        modelContext: ModelContext
    ) async -> [User] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }
        
        do {
            let lowercaseQuery = query.lowercased()
            
            let descriptor = FetchDescriptor<User>(
                predicate: #Predicate { user in
                    user.id != currentUser.id && user.allowDiscovery
                }
            )
            
            let allUsers = try modelContext.fetch(descriptor)
            
            let filteredUsers = allUsers.filter { user in
                user.username.lowercased().contains(lowercaseQuery) ||
                user.displayName.lowercased().contains(lowercaseQuery) ||
                user.bio.lowercased().contains(lowercaseQuery) ||
                user.interests.contains { $0.lowercased().contains(lowercaseQuery) }
            }
            
            return Array(filteredUsers.prefix(20))
            
        } catch {
            discoveryError = "Failed to search users: \(error.localizedDescription)"
            return []
        }
    }
} 