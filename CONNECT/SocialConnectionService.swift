//
//  SocialConnectionService.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class SocialConnectionService: ObservableObject {
    @Published var isProcessing = false
    @Published var connectionError: String?
    
    var notificationService: NotificationService?
    
    // MARK: - Friend Requests
    func sendFriendRequest(
        from sender: User,
        to receiver: User,
        message: String? = nil,
        modelContext: ModelContext
    ) async -> Bool {
        guard sender.id != receiver.id else {
            connectionError = "Cannot send friend request to yourself"
            return false
        }
        
        // Check if request already exists
        let descriptor = FetchDescriptor<FriendRequest>(
            predicate: #Predicate { request in
                request.sender?.id == sender.id && request.receiver?.id == receiver.id
            }
        )
        
        do {
            let existingRequests = try modelContext.fetch(descriptor)
            if !existingRequests.isEmpty {
                connectionError = "Friend request already sent"
                return false
            }
            
            isProcessing = true
            
            // Create friend request
            let friendRequest = FriendRequest(
                sender: sender,
                receiver: receiver,
                message: message
            )
            
            modelContext.insert(friendRequest)
            try modelContext.save()
            
            // Send notification
            await notificationService?.sendFriendRequestNotification(to: receiver, from: sender)
            
            // Track analytics
            AnalyticsManager.shared.track(.friendRequestSent)
            
            isProcessing = false
            return true
            
        } catch {
            connectionError = "Failed to send friend request: \(error.localizedDescription)"
            isProcessing = false
            return false
        }
    }
    
    func acceptFriendRequest(
        _ request: FriendRequest,
        modelContext: ModelContext
    ) async -> Bool {
        isProcessing = true
        
        do {
            request.accept()
            try modelContext.save()
            
            // Send notification to sender
            if let sender = request.sender, let receiver = request.receiver {
                await notificationService?.sendFriendRequestAcceptedNotification(to: sender, from: receiver)
            }
            
            isProcessing = false
            return true
            
        } catch {
            connectionError = "Failed to accept friend request: \(error.localizedDescription)"
            isProcessing = false
            return false
        }
    }
    
    func declineFriendRequest(
        _ request: FriendRequest,
        modelContext: ModelContext
    ) async -> Bool {
        isProcessing = true
        
        do {
            request.decline()
            try modelContext.save()
            
            isProcessing = false
            return true
            
        } catch {
            connectionError = "Failed to decline friend request: \(error.localizedDescription)"
            isProcessing = false
            return false
        }
    }
    
    // MARK: - Friendships
    func removeFriend(
        user: User,
        friend: User,
        modelContext: ModelContext
    ) async -> Bool {
        isProcessing = true
        
        do {
            // Remove from friends lists
            user.friends.removeAll { $0.id == friend.id }
            friend.friends.removeAll { $0.id == user.id }
            
            // Update counts
            user.followingCount = max(0, user.followingCount - 1)
            friend.followersCount = max(0, friend.followersCount - 1)
            
            try modelContext.save()
            
            isProcessing = false
            return true
            
        } catch {
            connectionError = "Failed to remove friend: \(error.localizedDescription)"
            isProcessing = false
            return false
        }
    }
    
    // MARK: - Helper Methods
    func areFriends(_ user1: User, _ user2: User) -> Bool {
        return user1.friends.contains { $0.id == user2.id }
    }
    
    func hasPendingRequest(from sender: User, to receiver: User, modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<FriendRequest>(
            predicate: #Predicate { request in
                request.sender?.id == sender.id && 
                request.receiver?.id == receiver.id && 
                request.status == FriendRequestStatus.pending
            }
        )
        
        do {
            let requests = try modelContext.fetch(descriptor)
            return !requests.isEmpty
        } catch {
            return false
        }
    }
} 