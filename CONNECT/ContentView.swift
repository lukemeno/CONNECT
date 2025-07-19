//
//  ContentView.swift
//  CONNECT
//
//  Created by Luke on 19.07.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @State private var selectedTab = 0
    @State private var showCreateMoment = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Feed Tab
            FeedView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Feed")
                }
                .tag(0)
            
            // Discover Tab
            UserDiscoveryView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    Text("Discover")
                }
                .tag(1)
            
            // Create Tab
            Color.clear
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Create")
                }
                .tag(2)
                .onAppear {
                    if selectedTab == 2 {
                        showCreateMoment = true
                        selectedTab = 0 // Reset to feed
                    }
                }
            
            // Notifications Tab
            NotificationsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "bell.fill" : "bell")
                    Text("Notifications")
                }
                .tag(3)
                .badge(container.notificationService.unreadNotificationsCount > 0 ? container.notificationService.unreadNotificationsCount : nil)
            
            // Profile Tab
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                    Text("Profile")
                }
                .tag(4)
        }
        .tint(.blue)
        .sheet(isPresented: $showCreateMoment) {
            EnhancedCreateMomentView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(DependencyContainer().authenticationManager)
        .environmentObject(DependencyContainer())
        .modelContainer(for: User.self, inMemory: true)
}