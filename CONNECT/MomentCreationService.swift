//
//  MomentCreationService.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class MomentCreationService: ObservableObject {
    @Published var isCreating = false
    @Published var creationError: String?
    
    var mediaProcessingService: MediaProcessingService?
    
    func createMoment(
        content: String,
        author: User,
        mediaURLs: [String] = [],
        privacy: MomentPrivacy = .friends,
        hashtags: [String] = [],
        feeling: String? = nil,
        activity: String? = nil,
        location: Location? = nil,
        modelContext: ModelContext
    ) async -> Bool {
        isCreating = true
        creationError = nil
        
        do {
            // Process media if needed
            var processedMediaURLs = mediaURLs
            if !mediaURLs.isEmpty {
                processedMediaURLs = await mediaProcessingService?.processMedia(urls: mediaURLs) ?? mediaURLs
            }
            
            // Determine media type
            let mediaType: MediaType = {
                if processedMediaURLs.isEmpty {
                    return .none
                } else if processedMediaURLs.first?.contains(".mp4") == true {
                    return .video
                } else {
                    return .image
                }
            }()
            
            // Create the moment
            let moment = Moment(
                content: content,
                author: author,
                mediaURLs: processedMediaURLs,
                mediaType: mediaType,
                privacy: privacy,
                hashtags: hashtags,
                feeling: feeling,
                activity: activity,
                location: location
            )
            
            // Save to SwiftData
            modelContext.insert(moment)
            try modelContext.save()
            
            // Update user stats
            author.momentsCount += 1
            
            // Track analytics
            AnalyticsManager.shared.track(.momentCreated)
            
            isCreating = false
            return true
            
        } catch {
            creationError = "Failed to create moment: \(error.localizedDescription)"
            isCreating = false
            return false
        }
    }
    
    func extractHashtags(from text: String) -> [String] {
        let pattern = #"#\w+"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = regex?.matches(in: text, range: range) ?? []
        
        return matches.compactMap { match in
            if let range = Range(match.range, in: text) {
                return String(text[range])
            }
            return nil
        }
    }
}

// MARK: - Media Processing Service
@MainActor
class MediaProcessingService: ObservableObject {
    func processMedia(urls: [String]) async -> [String] {
        // Process media (resize images, compress videos, etc.)
        // For demo purposes, return the original URLs
        return urls
    }
    
    func compressImage(url: String) async -> String {
        // Image compression logic
        return url
    }
    
    func compressVideo(url: String) async -> String {
        // Video compression logic
        return url
    }
} 