//
//  FeedAlgorithmService.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class FeedAlgorithmService: ObservableObject {
    @Published var isLoading = false
    @Published var feedError: String?
    
    func generatePersonalizedFeed(
        for user: User,
        modelContext: ModelContext,
        limit: Int = 20
    ) async -> [Moment] {
        isLoading = true
        feedError = nil
        
        do {
            // Get moments from friends and public moments
            var allMoments: [Moment] = []
            
            // Friends' moments
            let friendsDescriptor = FetchDescriptor<Moment>(
                predicate: #Predicate<Moment> { moment in
                    moment.privacy == MomentPrivacy.friends || moment.privacy == MomentPrivacy.publicMoment
                },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            
            let friendsMoments = try modelContext.fetch(friendsDescriptor)
            
            // Filter moments from friends or user's own moments
            let filteredMoments = friendsMoments.filter { moment in
                guard let author = moment.author else { return false }
                
                // Include user's own moments
                if author.id == user.id { return true }
                
                // Include friends' moments
                if user.friends.contains(where: { $0.id == author.id }) {
                    return true
                }
                
                // Include public moments if privacy allows
                if moment.privacy == .publicMoment && author.allowDiscovery {
                    return true
                }
                
                return false
            }
            
            allMoments = filteredMoments
            
            // Apply personalization algorithm
            let personalizedMoments = applyPersonalizationAlgorithm(
                moments: allMoments,
                for: user
            )
            
            isLoading = false
            return Array(personalizedMoments.prefix(limit))
            
        } catch {
            feedError = "Failed to load feed: \(error.localizedDescription)"
            isLoading = false
            return []
        }
    }
    
    private func applyPersonalizationAlgorithm(moments: [Moment], for user: User) -> [Moment] {
        // Score moments based on various factors
        let scoredMoments = moments.map { moment -> (moment: Moment, score: Double) in
            var score = 0.0
            
            // Recency factor (newer posts get higher score)
            let hoursSincePosted = Date().timeIntervalSince(moment.createdAt) / 3600
            score += max(0, 100 - hoursSincePosted)
            
            // Engagement factor
            score += Double(moment.likesCount) * 2
            score += Double(moment.commentsCount) * 3
            score += Double(moment.sharesCount) * 1.5
            
            // Friend relationship factor
            if let author = moment.author {
                if user.friends.contains(where: { $0.id == author.id }) {
                    score += 50 // Boost friends' content
                }
                
                // Interest alignment
                let commonInterests = Set(user.interests).intersection(Set(author.interests))
                score += Double(commonInterests.count) * 10
            }
            
            // Content type preference (can be learned from user behavior)
            if moment.hasMedia {
                score += 20 // Boost visual content
            }
            
            // Hashtag relevance
            let userInterestHashtags = user.interests.map { "#\($0.lowercased())" }
            let commonHashtags = Set(moment.hashtags).intersection(Set(userInterestHashtags))
            score += Double(commonHashtags.count) * 15
            
            return (moment: moment, score: score)
        }
        
        // Sort by score and return moments
        return scoredMoments
            .sorted { $0.score > $1.score }
            .map { $0.moment }
    }
    
    // MARK: - Discovery Feed
    func generateDiscoveryFeed(
        for user: User,
        modelContext: ModelContext,
        limit: Int = 20
    ) async -> [Moment] {
        do {
            // Get trending public moments
            let descriptor = FetchDescriptor<Moment>(
                predicate: #Predicate<Moment> { moment in
                    moment.privacy == MomentPrivacy.publicMoment
                },
                sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
            )
            
            let publicMoments = try modelContext.fetch(descriptor)
            
            // Filter out moments from users the current user already follows
            let discoveryMoments = publicMoments.filter { moment in
                guard let author = moment.author else { return false }
                return !user.friends.contains(where: { $0.id == author.id }) && author.id != user.id
            }
            
            // Apply discovery algorithm (trending, popular, etc.)
            let trendingMoments = applyDiscoveryAlgorithm(
                moments: discoveryMoments,
                for: user
            )
            
            return Array(trendingMoments.prefix(limit))
            
        } catch {
            return []
        }
    }
    
    private func applyDiscoveryAlgorithm(moments: [Moment], for user: User) -> [Moment] {
        let now = Date()
        
        // Score moments for discovery
        let scoredMoments = moments.map { moment -> (moment: Moment, score: Double) in
            var score = 0.0
            
            // Trending factor (high engagement in short time)
            let hoursSincePosted = now.timeIntervalSince(moment.createdAt) / 3600
            if hoursSincePosted < 24 {
                let engagementRate = Double(moment.likesCount + moment.commentsCount) / max(1, hoursSincePosted)
                score += engagementRate * 10
            }
            
            // Total engagement
            score += Double(moment.likesCount + moment.commentsCount + moment.sharesCount)
            
            // Interest alignment
            if let author = moment.author {
                let commonInterests = Set(user.interests).intersection(Set(author.interests))
                score += Double(commonInterests.count) * 5
            }
            
            // Media bonus for discovery
            if moment.hasMedia {
                score += 30
            }
            
            return (moment: moment, score: score)
        }
        
        return scoredMoments
            .sorted { $0.score > $1.score }
            .map { $0.moment }
    }
}  