//
//  NotificationService.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftUI
import UserNotifications

@MainActor
class NotificationService: ObservableObject {
    @Published var hasPermission = false
    @Published var notifications: [ConnectNotification] = []
    
    init() {
        checkNotificationPermission()
    }
    
    // MARK: - Permission Management
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.hasPermission = granted
            }
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Friend Request Notifications
    func sendFriendRequestNotification(to receiver: User, from sender: User) async {
        guard hasPermission else { return }
        
        let notification = ConnectNotification(
            id: UUID(),
            type: .friendRequest,
            title: "New Friend Request",
            message: "\(sender.displayName) sent you a friend request",
            fromUser: sender,
            toUser: receiver,
            createdAt: Date()
        )
        
        await scheduleLocalNotification(notification)
        await addToNotificationsList(notification)
    }
    
    func sendFriendRequestAcceptedNotification(to sender: User, from receiver: User) async {
        guard hasPermission else { return }
        
        let notification = ConnectNotification(
            id: UUID(),
            type: .friendRequestAccepted,
            title: "Friend Request Accepted",
            message: "\(receiver.displayName) accepted your friend request",
            fromUser: receiver,
            toUser: sender,
            createdAt: Date()
        )
        
        await scheduleLocalNotification(notification)
        await addToNotificationsList(notification)
    }
    
    // MARK: - Moment Notifications
    func sendMomentLikedNotification(moment: Moment, likedBy user: User) async {
        guard hasPermission, let author = moment.author else { return }
        
        let notification = ConnectNotification(
            id: UUID(),
            type: .momentLiked,
            title: "New Like",
            message: "\(user.displayName) liked your moment",
            fromUser: user,
            toUser: author,
            momentId: moment.id,
            createdAt: Date()
        )
        
        await scheduleLocalNotification(notification)
        await addToNotificationsList(notification)
    }
    
    func sendMomentCommentedNotification(moment: Moment, commentedBy user: User) async {
        guard hasPermission, let author = moment.author else { return }
        
        let notification = ConnectNotification(
            id: UUID(),
            type: .momentCommented,
            title: "New Comment",
            message: "\(user.displayName) commented on your moment",
            fromUser: user,
            toUser: author,
            momentId: moment.id,
            createdAt: Date()
        )
        
        await scheduleLocalNotification(notification)
        await addToNotificationsList(notification)
    }
    
    // MARK: - Private Methods
    private func scheduleLocalNotification(_ notification: ConnectNotification) async {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = .default
        content.badge = NSNumber(value: notifications.count + 1)
        
        let request = UNNotificationRequest(
            identifier: notification.id.uuidString,
            content: content,
            trigger: nil // Immediate delivery
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    private func addToNotificationsList(_ notification: ConnectNotification) async {
        await MainActor.run {
            self.notifications.insert(notification, at: 0)
            
            // Keep only the latest 50 notifications
            if self.notifications.count > 50 {
                self.notifications = Array(self.notifications.prefix(50))
            }
        }
    }
    
    // MARK: - Notification Management
    func markNotificationAsRead(_ notificationId: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
        }
    }
    
    func markAllNotificationsAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
    
    func clearNotifications() {
        notifications.removeAll()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    var unreadNotificationsCount: Int {
        notifications.filter { !$0.isRead }.count
    }
}

// MARK: - ConnectNotification Model
struct ConnectNotification: Identifiable, Codable {
    let id: UUID
    let type: NotificationType
    let title: String
    let message: String
    let fromUser: User?
    let toUser: User
    let momentId: UUID?
    let createdAt: Date
    var isRead: Bool = false
    
    enum NotificationType: String, Codable, CaseIterable {
        case friendRequest = "friend_request"
        case friendRequestAccepted = "friend_request_accepted"
        case momentLiked = "moment_liked"
        case momentCommented = "moment_commented"
        case momentShared = "moment_shared"
        case newFollower = "new_follower"
        case eventInvite = "event_invite"
        case communityInvite = "community_invite"
        
        var iconName: String {
            switch self {
            case .friendRequest, .friendRequestAccepted: return "person.crop.circle.fill.badge.plus"
            case .momentLiked: return "heart.fill"
            case .momentCommented: return "bubble.left.fill"
            case .momentShared: return "arrowshape.turn.up.right.fill"
            case .newFollower: return "person.fill.badge.plus"
            case .eventInvite: return "calendar.badge.plus"
            case .communityInvite: return "person.3.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .friendRequest, .friendRequestAccepted: return .blue
            case .momentLiked: return .red
            case .momentCommented: return .green
            case .momentShared: return .orange
            case .newFollower: return .purple
            case .eventInvite: return .indigo
            case .communityInvite: return .teal
            }
        }
    }
} 