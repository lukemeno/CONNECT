//
//  MomentCardView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI
import SwiftData

struct MomentCardView: View {
    let moment: Moment
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var container: DependencyContainer
    @EnvironmentObject var authManager: AuthenticationManager
    
    @State private var showReactionPicker = false
    @State private var showComments = false
    @State private var userReaction: Reaction?
    @State private var showShareSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            MomentHeaderView(moment: moment)
            
            // Content
            if !moment.content.isEmpty {
                Text(moment.content)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.bottom, moment.hasMedia ? 12 : 16)
            }
            
            // Media
            if moment.hasMedia {
                MomentMediaView(moment: moment)
            }
            
            // Engagement Stats
            if moment.likesCount > 0 || moment.commentsCount > 0 {
                EngagementStatsView(moment: moment)
            }
            
            // Action Buttons
            ActionButtonsView(
                moment: moment,
                userReaction: $userReaction,
                showReactionPicker: $showReactionPicker,
                showComments: $showComments,
                showShareSheet: $showShareSheet
            )
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .onAppear {
            loadUserReaction()
        }
        .sheet(isPresented: $showComments) {
            CommentsView(moment: moment)
        }
        .sheet(isPresented: $showReactionPicker) {
            ReactionPickerView(moment: moment, userReaction: $userReaction)
                .presentationDetents([.height(200)])
        }
    }
    
    private func loadUserReaction() {
        guard let currentUser = authManager.currentUser else { return }
        
        let userReactions = moment.reactions.filter { $0.user?.id == currentUser.id }
        userReaction = userReactions.first
    }
}

// MARK: - Moment Header
struct MomentHeaderView: View {
    let moment: Moment
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Picture
            AsyncImage(url: URL(string: moment.author?.profilePictureURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(moment.author?.displayName ?? "Unknown User")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if moment.author?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(moment.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let location = moment.location {
                        HStack(spacing: 2) {
                            Image(systemName: "location")
                                .font(.caption2)
                            Text(location.name)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Image(systemName: moment.privacy.systemImage)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // More Button
            Menu {
                Button("Share", systemImage: "square.and.arrow.up") {
                    // Handle share
                }
                
                if moment.author?.id == AuthenticationManager().currentUser?.id {
                    Button("Edit", systemImage: "pencil") {
                        // Handle edit
                    }
                    
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        // Handle delete
                    }
                }
                
                Button("Report", systemImage: "flag", role: .destructive) {
                    // Handle report
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
    }
}

// MARK: - Moment Media
struct MomentMediaView: View {
    let moment: Moment
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                ForEach(moment.mediaURLs, id: \.self) { mediaURL in
                    AsyncImage(url: URL(string: mediaURL)) { image in
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
                    .frame(width: 300, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
}

// MARK: - Engagement Stats
struct EngagementStatsView: View {
    let moment: Moment
    
    var body: some View {
        HStack {
            if moment.likesCount > 0 {
                HStack(spacing: 4) {
                    HStack(spacing: -4) {
                        ForEach(ReactionType.allCases.prefix(3), id: \.self) { reactionType in
                            Text(reactionType.emoji)
                                .font(.caption)
                                .padding(2)
                                .background(.white)
                                .clipShape(Circle())
                        }
                    }
                    
                    Text("\(moment.likesCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if moment.commentsCount > 0 {
                Text("\(moment.commentsCount) comments")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if moment.sharesCount > 0 {
                Text("\(moment.sharesCount) shares")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Action Buttons
struct ActionButtonsView: View {
    let moment: Moment
    @Binding var userReaction: Reaction?
    @Binding var showReactionPicker: Bool
    @Binding var showComments: Bool
    @Binding var showShareSheet: Bool
    
    var body: some View {
        HStack {
            // Like Button
            Button {
                showReactionPicker = true
            } label: {
                HStack(spacing: 6) {
                    if let userReaction = userReaction {
                        Text(userReaction.type.emoji)
                    } else {
                        Image(systemName: "heart")
                    }
                    Text("Like")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(userReaction != nil ? .blue : .secondary)
            }
            
            Spacer()
            
            // Comment Button
            Button {
                showComments = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left")
                    Text("Comment")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Share Button
            Button {
                showShareSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrowshape.turn.up.right")
                    Text("Share")
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.gray.opacity(0.05))
    }
}

// MARK: - Reaction Picker
struct ReactionPickerView: View {
    let moment: Moment
    @Binding var userReaction: Reaction?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("React to this moment")
                .font(.headline)
                .padding(.top)
            
            HStack(spacing: 20) {
                ForEach(ReactionType.allCases, id: \.self) { reactionType in
                    Button {
                        addReaction(type: reactionType)
                    } label: {
                        VStack(spacing: 8) {
                            Text(reactionType.emoji)
                                .font(.largeTitle)
                            
                            Text(reactionType.displayName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .scaleEffect(userReaction?.type == reactionType ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3), value: userReaction?.type)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func addReaction(type: ReactionType) {
        guard let currentUser = authManager.currentUser else { return }
        
        // Remove existing reaction
        if let existingReaction = userReaction {
            modelContext.delete(existingReaction)
            moment.decrementLikes()
            userReaction = nil
        }
        
        // Add new reaction if different type
        if userReaction?.type != type {
            let newReaction = Reaction(type: type, user: currentUser, moment: moment)
            modelContext.insert(newReaction)
            moment.incrementLikes()
            userReaction = newReaction
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    let container = DependencyContainer()
    let user = User(username: "john_doe", displayName: "John Doe", email: "john@example.com")
    let moment = Moment(content: "Just had an amazing coffee! ☕️", author: user)
    
    return MomentCardView(moment: moment)
        .environmentObject(container)
        .environmentObject(container.authenticationManager)
        .padding()
} 