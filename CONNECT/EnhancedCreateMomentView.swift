//
//  EnhancedCreateMomentView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI
import PhotosUI
import SwiftData

struct EnhancedCreateMomentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @State private var content = ""
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var processedImages: [UIImage] = []
    @State private var privacy: MomentPrivacy = .friends
    @State private var feeling = ""
    @State private var activity = ""
    @State private var location: Location?
    @State private var hashtags: [String] = []
    @State private var showPhotoPicker = false
    @State private var showLocationPicker = false
    @State private var isCreating = false
    
    let feelings = ["😊 Happy", "😍 Loved", "🎉 Excited", "😌 Relaxed", "💪 Motivated", "🤔 Thoughtful", "😴 Tired", "🍕 Hungry"]
    let activities = ["🎵 Listening to music", "📚 Reading", "🏃‍♂️ Working out", "🍳 Cooking", "✈️ Traveling", "🎨 Creating", "🎮 Gaming", "📺 Watching"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // User Header
                    if let user = authManager.currentUser {
                        UserHeaderView(user: user)
                    }
                    
                    // Text Content
                    TextContentSection(content: $content, hashtags: $hashtags)
                    
                    // Media Section
                    MediaSection(
                        selectedImages: $selectedImages,
                        processedImages: $processedImages,
                        showPhotoPicker: $showPhotoPicker
                    )
                    
                    // Feeling & Activity
                    FeelingActivitySection(
                        feeling: $feeling,
                        activity: $activity,
                        feelings: feelings,
                        activities: activities
                    )
                    
                    // Location
                    LocationSection(
                        location: $location,
                        showLocationPicker: $showLocationPicker
                    )
                    
                    // Privacy
                    PrivacySection(privacy: $privacy)
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Create Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createMoment()
                    }
                    .fontWeight(.semibold)
                    .disabled(content.isEmpty || isCreating)
                }
            }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedImages, maxSelectionCount: 5, matching: .images)
        .onChange(of: selectedImages) { _, newItems in
            Task {
                await processSelectedImages(newItems)
            }
        }
    }
    
    private func createMoment() {
        guard let currentUser = authManager.currentUser else { return }
        
        isCreating = true
        
        Task {
            // Extract hashtags from content
            let extractedHashtags = container.momentCreationService.extractHashtags(from: content)
            let allHashtags = hashtags + extractedHashtags
            
            let success = await container.momentCreationService.createMoment(
                content: content,
                author: currentUser,
                mediaURLs: [], // In real app, upload images first
                privacy: privacy,
                hashtags: Array(Set(allHashtags)), // Remove duplicates
                feeling: feeling.isEmpty ? nil : feeling,
                activity: activity.isEmpty ? nil : activity,
                location: location,
                modelContext: modelContext
            )
            
            await MainActor.run {
                isCreating = false
                if success {
                    dismiss()
                }
            }
        }
    }
    
    private func processSelectedImages(_ items: [PhotosPickerItem]) async {
        var images: [UIImage] = []
        
        for item in items {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    images.append(image)
                }
            } catch {
                print("Failed to process image: \(error)")
                continue
            }
        }
        
        await MainActor.run {
            self.processedImages = images
        }
    }
}

// MARK: - User Header
struct UserHeaderView: View {
    let user: User
    
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
                Text(user.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("@\(user.username)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Text Content Section
struct TextContentSection: View {
    @Binding var content: String
    @Binding var hashtags: [String]
    @FocusState private var isTextFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("What's on your mind?")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $content)
                    .focused($isTextFocused)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
            }
            .background(.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Hashtag suggestions
            if !hashtags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(hashtags, id: \.self) { hashtag in
                            HashtagChip(hashtag: hashtag) {
                                hashtags.removeAll { $0 == hashtag }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Media Section
struct MediaSection: View {
    @Binding var selectedImages: [PhotosPickerItem]
    @Binding var processedImages: [UIImage]
    @Binding var showPhotoPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !processedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(processedImages.enumerated()), id: \.offset) { index, image in
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                Button {
                                    if index < processedImages.count && index < selectedImages.count {
                                        processedImages.remove(at: index)
                                        selectedImages.remove(at: index)
                                    }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding(4)
                            }
                        }
                        
                        // Add more button
                        if processedImages.count < 5 {
                            Button {
                                showPhotoPicker = true
                            } label: {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.gray.opacity(0.2))
                                    .frame(width: 100, height: 100)
                                    .overlay {
                                        Image(systemName: "plus")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Media options
            HStack(spacing: 20) {
                MediaButton(icon: "photo", title: "Photos") {
                    showPhotoPicker = true
                }
                
                MediaButton(icon: "camera", title: "Camera") {
                    // Handle camera
                }
                
                MediaButton(icon: "video", title: "Video") {
                    // Handle video
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Feeling & Activity Section
struct FeelingActivitySection: View {
    @Binding var feeling: String
    @Binding var activity: String
    let feelings: [String]
    let activities: [String]
    
    var body: some View {
        VStack(spacing: 16) {
            // Feeling
            VStack(alignment: .leading, spacing: 8) {
                Text("How are you feeling?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(feelings, id: \.self) { feelingOption in
                            SelectionChip(
                                text: feelingOption,
                                isSelected: feeling == feelingOption
                            ) {
                                feeling = feeling == feelingOption ? "" : feelingOption
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            // Activity
            VStack(alignment: .leading, spacing: 8) {
                Text("What are you doing?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(activities, id: \.self) { activityOption in
                            SelectionChip(
                                text: activityOption,
                                isSelected: activity == activityOption
                            ) {
                                activity = activity == activityOption ? "" : activityOption
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Location Section
struct LocationSection: View {
    @Binding var location: Location?
    @Binding var showLocationPicker: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.blue)
                
                if let location = location {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(location.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(location.shortAddress)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Remove") {
                        self.location = nil
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                } else {
                    Text("Add location")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if location == nil {
                    showLocationPicker = true
                }
            }
        }
        .padding()
        .background(.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Privacy Section
struct PrivacySection: View {
    @Binding var privacy: MomentPrivacy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Who can see this?")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 16) {
                ForEach(MomentPrivacy.allCases, id: \.self) { privacyOption in
                    PrivacyButton(
                        privacy: privacyOption,
                        isSelected: privacy == privacyOption
                    ) {
                        privacy = privacyOption
                    }
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Supporting Views
struct MediaButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(.blue)
        }
    }
}

struct HashtagChip: View {
    let hashtag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(hashtag)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(.blue.opacity(0.2))
        .foregroundColor(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SelectionChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? .blue : .gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

struct PrivacyButton: View {
    let privacy: MomentPrivacy
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: privacy.systemImage)
                    .font(.system(size: 14))
                
                Text(privacy.displayName)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? .blue : .gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    EnhancedCreateMomentView()
        .environmentObject(DependencyContainer().authenticationManager)
        .environmentObject(DependencyContainer())
}       