//
//  NotificationsView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var container: DependencyContainer
    
    var body: some View {
        NavigationView {
            Group {
                if container.notificationService.notifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    List {
                        ForEach(container.notificationService.notifications) { notification in
                            NotificationRow(notification: notification)
                                .onTapGesture {
                                    container.notificationService.markNotificationAsRead(notification.id)
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if !container.notificationService.notifications.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Mark All as Read", systemImage: "checkmark.circle") {
                                container.notificationService.markAllNotificationsAsRead()
                            }
                            
                            Button("Clear All", systemImage: "trash", role: .destructive) {
                                container.notificationService.clearNotifications()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: ConnectNotification
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: notification.type.iconName)
                    .font(.system(size: 18))
                    .foregroundColor(notification.type.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(notification.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text(timeAgo(from: notification.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if !notification.isRead {
                        Circle()
                            .fill(.blue)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(notification.isRead ? .clear : .blue.opacity(0.05))
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Empty Notifications
struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.slash")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Text("No notifications yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("When someone likes your posts, sends you a friend request, or comments on your moments, you'll see it here")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            NavigationLink(destination: UserDiscoveryView()) {
                HStack {
                    Image(systemName: "person.2.circle")
                    Text("Discover Friends")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NotificationsView()
        .environmentObject(DependencyContainer())
} 