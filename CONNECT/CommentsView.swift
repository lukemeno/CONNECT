//
//  CommentsView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI
import SwiftData

struct CommentsView: View {
    let moment: Moment
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @State private var newCommentText = ""
    @State private var replyingTo: Comment?
    @State private var isPosting = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Moment Summary
                MomentSummaryView(moment: moment)
                
                Divider()
                
                // Comments List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(rootComments) { comment in
                            CommentRowView(
                                comment: comment,
                                moment: moment,
                                replyingTo: $replyingTo
                            )
                            .environmentObject(container)
                            
                            // Replies
                            ForEach(comment.replies) { reply in
                                CommentRowView(
                                    comment: reply,
                                    moment: moment,
                                    replyingTo: $replyingTo,
                                    isReply: true
                                )
                                .environmentObject(container)
                                .padding(.leading, 32)
                            }
                        }
                    }
                }
                
                // Comment Input
                CommentInputView(
                    newCommentText: $newCommentText,
                    replyingTo: $replyingTo,
                    isPosting: $isPosting,
                    isTextFieldFocused: $isTextFieldFocused,
                    onPost: postComment
                )
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            isTextFieldFocused = true
        }
    }
    
    private var rootComments: [Comment] {
        moment.comments.filter { $0.parentComment == nil }
            .sorted { $0.createdAt < $1.createdAt }
    }
    
    private func postComment() {
        guard let currentUser = authManager.currentUser,
              !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isPosting = true
        
        let comment = Comment(
            content: newCommentText.trimmingCharacters(in: .whitespacesAndNewlines),
            author: currentUser,
            moment: replyingTo == nil ? moment : nil,
            parentComment: replyingTo
        )
        
        modelContext.insert(comment)
        
        // Update counts
        if replyingTo != nil {
            replyingTo?.incrementReplies()
        } else {
            moment.incrementComments()
        }
        
        // Send notification
        if let momentAuthor = moment.author, momentAuthor.id != currentUser.id {
            Task {
                await container.notificationService.sendMomentCommentedNotification(
                    moment: moment,
                    commentedBy: currentUser
                )
            }
        }
        
        do {
            try modelContext.save()
            
            // Reset input
            newCommentText = ""
            replyingTo = nil
            isPosting = false
        } catch {
            print("Failed to save comment: \(error)")
            isPosting = false
        }
    }
}

// MARK: - Moment Summary
struct MomentSummaryView: View {
    let moment: Moment
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: moment.author?.profilePictureURL ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.gray)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(moment.author?.displayName ?? "Unknown User")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(moment.displayContent)
                    .font(.body)
                    .lineLimit(2)
                
                Text(moment.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Comment Row
struct CommentRowView: View {
    let comment: Comment
    let moment: Moment
    @Binding var replyingTo: Comment?
    var isReply = false
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @State private var userReaction: Reaction?
    @State private var showReactionPicker = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: comment.author?.profilePictureURL ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: isReply ? 32 : 36, height: isReply ? 32 : 36)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 6) {
                    // Author and content
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(comment.author?.displayName ?? "Unknown")
                                .font(isReply ? .caption : .subheadline)
                                .fontWeight(.semibold)
                            
                            Text(comment.timeAgo)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        
                        Text(comment.content)
                            .font(isReply ? .caption : .body)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    // Actions
                    HStack(spacing: 16) {
                        // Like button
                        Button {
                            toggleReaction()
                        } label: {
                            HStack(spacing: 4) {
                                if let userReaction = userReaction {
                                    Text(userReaction.type.emoji)
                                        .font(.caption)
                                } else {
                                    Image(systemName: "heart")
                                        .font(.caption)
                                }
                                
                                if comment.likesCount > 0 {
                                    Text("\(comment.likesCount)")
                                        .font(.caption)
                                }
                            }
                            .foregroundColor(userReaction != nil ? .red : .secondary)
                        }
                        
                        // Reply button
                        if !isReply {
                            Button {
                                replyingTo = comment
                            } label: {
                                Text("Reply")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .onAppear {
            loadUserReaction()
        }
    }
    
    private func loadUserReaction() {
        guard let currentUser = authManager.currentUser else { return }
        userReaction = comment.reactions.first { $0.user?.id == currentUser.id }
    }
    
    private func toggleReaction() {
        guard let currentUser = authManager.currentUser else { return }
        
        if let existingReaction = userReaction {
            // Remove reaction
            modelContext.delete(existingReaction)
            comment.decrementLikes()
            userReaction = nil
        } else {
            // Add reaction
            let newReaction = Reaction(type: .like, user: currentUser, comment: comment)
            modelContext.insert(newReaction)
            comment.incrementLikes()
            userReaction = newReaction
        }
        
        try? modelContext.save()
    }
}

// MARK: - Comment Input
struct CommentInputView: View {
    @Binding var newCommentText: String
    @Binding var replyingTo: Comment?
    @Binding var isPosting: Bool
    var isTextFieldFocused: FocusState<Bool>.Binding
    let onPost: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if let replyingTo = replyingTo {
                HStack {
                    Text("Replying to \(replyingTo.author?.displayName ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Cancel") {
                        self.replyingTo = nil
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            HStack(spacing: 12) {
                TextField(replyingTo != nil ? "Write a reply..." : "Write a comment...", text: $newCommentText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused(isTextFieldFocused)
                    .lineLimit(1...4)
                
                Button {
                    onPost()
                } label: {
                    if isPosting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.title3)
                    }
                }
                .foregroundColor(.blue)
                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isPosting)
            }
            .padding()
        }
        .background(.regularMaterial)
    }
}

#Preview {
    let container = DependencyContainer()
    let user = User(username: "john_doe", displayName: "John Doe", email: "john@example.com")
    let moment = Moment(content: "Great day at the beach!", author: user)
    
    return CommentsView(moment: moment)
        .environmentObject(container)
        .environmentObject(container.authenticationManager)
} 