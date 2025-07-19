//
//  ProfileView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @Query private var userMoments: [Moment]
    @State private var showSettings = false
    @State private var showEditProfile = false
    
    private var currentUser: User? {
        authManager.currentUser
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = currentUser {
                        // Profile Header
                        ProfileHeaderView(user: user, showEditProfile: $showEditProfile)
                        
                        // Stats
                        ProfileStatsView(user: user)
                        
                        // Bio & Interests
                        ProfileInfoView(user: user)
                        
                        // Moments Grid
                        if !userMoments.isEmpty {
                            ProfileMomentsView(moments: userMoments)
                        } else {
                            EmptyProfileView()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit Profile", systemImage: "pencil") {
                            showEditProfile = true
                        }
                        
                        Button("Settings", systemImage: "gear") {
                            showSettings = true
                        }
                        
                        Divider()
                        
                        Button("Sign Out", systemImage: "rectangle.portrait.and.arrow.right", role: .destructive) {
                            authManager.signOut()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
    }
    
    init() {
        // Filter moments by current user
        let userId = DependencyContainer().authenticationManager.currentUser?.id ?? UUID()
        _userMoments = Query(
            filter: #Predicate<Moment> { moment in
                moment.author?.id == userId
            },
            sort: \Moment.createdAt,
            order: .reverse
        )
    }
}

// MARK: - Profile Header
struct ProfileHeaderView: View {
    let user: User
    @Binding var showEditProfile: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Profile Image
            AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(.white, lineWidth: 4)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            
            VStack(spacing: 4) {
                HStack {
                    Text(user.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    if user.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if user.isOnline {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        
                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Button("Edit Profile") {
                showEditProfile = true
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 18))
        }
    }
}

// MARK: - Profile Stats
struct ProfileStatsView: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 40) {
            StatItem(title: "Posts", value: user.momentsCount)
            StatItem(title: "Followers", value: user.followersCount)
            StatItem(title: "Following", value: user.followingCount)
        }
        .padding(.vertical, 16)
        .background(.gray.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct StatItem: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Profile Info
struct ProfileInfoView: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if !user.bio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(user.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            if !user.interests.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Interests")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    FlowLayout(data: user.interests, spacing: 8) { interest in
                        Text(interest)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            
            // Join Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Member Since")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(user.dateJoined.formatted(date: .abbreviated, time: .omitted))
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Profile Moments
struct ProfileMomentsView: View {
    let moments: [Moment]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Posts")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(moments) { moment in
                    MomentThumbnail(moment: moment)
                }
            }
        }
    }
}

struct MomentThumbnail: View {
    let moment: Moment
    
    var body: some View {
        ZStack {
            if moment.hasMedia, let firstMediaURL = moment.mediaURLs.first {
                AsyncImage(url: URL(string: firstMediaURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                        }
                }
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray.opacity(0.1))
                    .overlay {
                        VStack {
                            Image(systemName: "text.quote")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Text(moment.content)
                                .font(.caption)
                                .lineLimit(3)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                    }
            }
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Empty Profile
struct EmptyProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No posts yet")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Share your first moment to get started")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            NavigationLink(destination: EnhancedCreateMomentView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create First Post")
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
        .padding(40)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    SettingsRow(icon: "person.circle", title: "Edit Profile", action: {})
                    SettingsRow(icon: "lock", title: "Privacy", action: {})
                    SettingsRow(icon: "bell", title: "Notifications", action: {})
                }
                
                Section("Support") {
                    SettingsRow(icon: "questionmark.circle", title: "Help Center", action: {})
                    SettingsRow(icon: "envelope", title: "Contact Us", action: {})
                    SettingsRow(icon: "star", title: "Rate App", action: {})
                }
                
                Section("Legal") {
                    SettingsRow(icon: "doc.text", title: "Terms of Service", action: {})
                    SettingsRow(icon: "hand.raised", title: "Privacy Policy", action: {})
                }
                
                Section {
                    Button("Sign Out") {
                        authManager.signOut()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var displayName = ""
    @State private var bio = ""
    @State private var interests: [String] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Basic Info") {
                    TextField("Display Name", text: $displayName)
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Interests") {
                    // Add interest editing UI here
                    ForEach(interests, id: \.self) { interest in
                        Text(interest)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            loadCurrentData()
        }
    }
    
    private func loadCurrentData() {
        guard let user = authManager.currentUser else { return }
        displayName = user.displayName
        bio = user.bio
        interests = user.interests
    }
    
    private func saveProfile() {
        guard let user = authManager.currentUser else { return }
        
        user.displayName = displayName
        user.bio = bio
        user.interests = interests
        
        authManager.updateCurrentUser(user)
        dismiss()
    }
}

#Preview {
    ProfileView()
        .environmentObject(DependencyContainer().authenticationManager)
        .environmentObject(DependencyContainer())
} 