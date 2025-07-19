//
//  FeedView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @State private var moments: [Moment] = []
    @State private var isLoading = false
    @State private var showCreateMoment = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if moments.isEmpty && !isLoading {
                    EmptyFeedView(showCreateMoment: $showCreateMoment)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(moments) { moment in
                                MomentCardView(moment: moment)
                                    .environmentObject(container)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                    .refreshable {
                        await loadFeed()
                    }
                }
                
                if isLoading {
                    ProgressView("Loading your feed...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemBackground).opacity(0.8))
                }
            }
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateMoment = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        if let user = authManager.currentUser {
                            AsyncImage(url: URL(string: user.profilePictureURL ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await loadFeed()
            }
        }
        .sheet(isPresented: $showCreateMoment) {
            EnhancedCreateMomentView()
        }
    }
    
    private func loadFeed() async {
        guard let currentUser = authManager.currentUser else { return }
        
        isLoading = true
        
        do {
            let feedMoments = await container.feedAlgorithmService.generatePersonalizedFeed(
                for: currentUser,
                modelContext: modelContext
            )
            
            await MainActor.run {
                self.moments = feedMoments
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                print("Failed to load feed: \(error)")
            }
        }
    }
}

// MARK: - Empty Feed View
struct EmptyFeedView: View {
    @Binding var showCreateMoment: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "house.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Text("Welcome to Connect!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Start by creating your first moment or discovering new friends")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                Button {
                    showCreateMoment = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create Your First Moment")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
                
                NavigationLink(destination: UserDiscoveryView()) {
                    HStack {
                        Image(systemName: "person.2.circle")
                        Text("Discover Friends")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
            }
            .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FeedView()
        .environmentObject(DependencyContainer().authenticationManager)
        .environmentObject(DependencyContainer())
}     