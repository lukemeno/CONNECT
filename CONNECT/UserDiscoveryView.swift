//
//  UserDiscoveryView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI
import SwiftData

struct UserDiscoveryView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @State private var selectedCategory: UserDiscoveryService.DiscoveryCategory = .all
    @State private var suggestedUsers: [User] = []
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isLoading = false
    @State private var showSearch = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                if showSearch {
                    SearchBarView(
                        searchText: $searchText,
                        searchResults: $searchResults,
                        showSearch: $showSearch
                    )
                    .environmentObject(container)
                }
                
                // Category Filter
                CategoryFilterView(selectedCategory: $selectedCategory)
                
                // Content
                ScrollView {
                    if searchText.isEmpty {
                        // Discovery Grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(suggestedUsers) { user in
                                UserDiscoveryCard(user: user)
                                    .environmentObject(container)
                            }
                        }
                        .padding()
                    } else {
                        // Search Results
                        LazyVStack(spacing: 12) {
                            ForEach(searchResults) { user in
                                UserSearchResultRow(user: user)
                                    .environmentObject(container)
                            }
                        }
                        .padding()
                    }
                    
                    if suggestedUsers.isEmpty && !isLoading && searchText.isEmpty {
                        EmptyDiscoveryView()
                    }
                }
                .refreshable {
                    await loadUsers()
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation {
                            showSearch.toggle()
                        }
                    } label: {
                        Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                            .font(.title2)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadUsers()
            }
        }
        .onChange(of: selectedCategory) { _, _ in
            Task {
                await loadUsers()
            }
        }
        .onChange(of: searchText) { _, newValue in
            Task {
                await searchUsers(query: newValue)
            }
        }
    }
    
    private func loadUsers() async {
        guard let currentUser = authManager.currentUser else { return }
        
        isLoading = true
        
        let users = await container.userDiscoveryService.discoverUsers(
            for: currentUser,
            category: selectedCategory,
            modelContext: modelContext
        )
        
        await MainActor.run {
            self.suggestedUsers = users
            self.isLoading = false
        }
    }
    
    private func searchUsers(query: String) async {
        guard let currentUser = authManager.currentUser,
              !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            await MainActor.run {
                self.searchResults = []
            }
            return
        }
        
        let results = await container.userDiscoveryService.searchUsers(
            query: query,
            currentUser: currentUser,
            modelContext: modelContext
        )
        
        await MainActor.run {
            self.searchResults = results
        }
    }
}

// MARK: - Search Bar
struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var searchResults: [User]
    @Binding var showSearch: Bool
    @EnvironmentObject var container: DependencyContainer
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search users...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            Button("Cancel") {
                withAnimation {
                    showSearch = false
                    searchText = ""
                }
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
}

// MARK: - Category Filter
struct CategoryFilterView: View {
    @Binding var selectedCategory: UserDiscoveryService.DiscoveryCategory
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(UserDiscoveryService.DiscoveryCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(.gray.opacity(0.05))
    }
}

// MARK: - User Discovery Card
struct UserDiscoveryCard: View {
    let user: User
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @State private var hasPendingRequest = false
    @State private var areFriends = false
    @State private var isProcessing = false
    
    var body: some View {
        VStack(spacing: 12) {
            // Profile Image
            AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            
            VStack(spacing: 4) {
                HStack {
                    Text(user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
            }
            
            // Stats
            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    Text("\(user.momentsCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Posts")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 2) {
                    Text("\(user.followersCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Followers")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Common Interests
            if !user.interests.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(user.interests.prefix(3), id: \.self) { interest in
                            Text(interest)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
            
            // Action Button
            ActionButton(
                user: user,
                areFriends: areFriends,
                hasPendingRequest: hasPendingRequest,
                isProcessing: isProcessing
            ) {
                await sendFriendRequest()
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            checkFriendshipStatus()
        }
    }
    
    private func checkFriendshipStatus() {
        guard let currentUser = authManager.currentUser else { return }
        
        areFriends = container.socialConnectionService.areFriends(currentUser, user)
        hasPendingRequest = container.socialConnectionService.hasPendingRequest(
            from: currentUser,
            to: user,
            modelContext: modelContext
        )
    }
    
    private func sendFriendRequest() async {
        guard let currentUser = authManager.currentUser else { return }
        
        isProcessing = true
        
        let success = await container.socialConnectionService.sendFriendRequest(
            from: currentUser,
            to: user,
            modelContext: modelContext
        )
        
        await MainActor.run {
            self.isProcessing = false
            if success {
                self.hasPendingRequest = true
            }
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let user: User
    let areFriends: Bool
    let hasPendingRequest: Bool
    let isProcessing: Bool
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            Group {
                if isProcessing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if areFriends {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                        Text("Friends")
                    }
                } else if hasPendingRequest {
                    Text("Pending")
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Connect")
                    }
                }
            }
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(areFriends ? .green : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(areFriends ? .green.opacity(0.2) : .blue)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(isProcessing || areFriends || hasPendingRequest)
    }
}

// MARK: - User Search Result Row
struct UserSearchResultRow: View {
    let user: User
    @EnvironmentObject var container: DependencyContainer
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(user.followersCount)")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("followers")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: UserDiscoveryService.DiscoveryCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: category.systemImage)
                    .font(.caption)
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? .blue : .gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Empty Discovery View
struct EmptyDiscoveryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.3.sequence")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No users found")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Try adjusting your filters or check back later for new users to discover")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    UserDiscoveryView()
        .environmentObject(DependencyContainer().authenticationManager)
        .environmentObject(DependencyContainer())
} 