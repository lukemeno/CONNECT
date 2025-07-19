//
//  MediaProcessingService.swift
//  CONNECT
//
//  Created by Connect Team
//

import UIKit
import SwiftUI
import Photos
import AVFoundation

@MainActor
class MediaProcessingService: ObservableObject {
    
    // MARK: - Properties
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    
    private let maxImageSize: CGFloat = 1024
    private let compressionQuality: CGFloat = 0.8
    
    // MARK: - Image Processing
    func processImages(_ images: [UIImage]) async -> [ProcessedMedia] {
        isProcessing = true
        processingProgress = 0.0
        
        var processedMedia: [ProcessedMedia] = []
        
        for (index, image) in images.enumerated() {
            let processed = await processImage(image)
            processedMedia.append(processed)
            
            // Update progress
            processingProgress = Double(index + 1) / Double(images.count)
        }
        
        isProcessing = false
        return processedMedia
    }
    
    private func processImage(_ image: UIImage) async -> ProcessedMedia {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                // Resize image if needed
                let resizedImage = self.resizeImage(image, to: self.maxImageSize)
                
                // Compress image
                let imageData = resizedImage.jpegData(compressionQuality: self.compressionQuality) ?? Data()
                
                // Generate thumbnail
                let thumbnail = self.generateThumbnail(from: resizedImage)
                
                // Create processed media object
                let processedMedia = ProcessedMedia(
                    id: UUID(),
                    type: .image,
                    originalData: imageData,
                    thumbnailData: thumbnail.jpegData(compressionQuality: 0.6) ?? Data(),
                    fileSize: imageData.count,
                    dimensions: CGSize(width: resizedImage.size.width, height: resizedImage.size.height)
                )
                
                continuation.resume(returning: processedMedia)
            }
        }
    }
    
    // MARK: - Video Processing
    func processVideo(from url: URL) async -> ProcessedMedia? {
        isProcessing = true
        processingProgress = 0.0
        
        return await withCheckedContinuation { continuation in
            let asset = AVAsset(url: url)
            
            // Get video information
            Task {
                do {
                    let duration = try await asset.load(.duration)
                    let tracks = try await asset.loadTracks(withMediaType: .video)
                    
                    guard let videoTrack = tracks.first else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let naturalSize = try await videoTrack.load(.naturalSize)
                    
                    // Generate thumbnail
                    let thumbnail = await self.generateVideoThumbnail(from: asset)
                    
                    // For demo purposes, we'll just reference the original URL
                    // In a real app, you'd compress and upload the video
                    let processedMedia = ProcessedMedia(
                        id: UUID(),
                        type: .video,
                        originalData: Data(), // Would contain compressed video data
                        thumbnailData: thumbnail?.jpegData(compressionQuality: 0.6) ?? Data(),
                        fileSize: 0, // Would get actual file size
                        dimensions: naturalSize,
                        duration: CMTimeGetSeconds(duration),
                        originalURL: url
                    )
                    
                    await MainActor.run {
                        self.isProcessing = false
                        self.processingProgress = 1.0
                    }
                    
                    continuation.resume(returning: processedMedia)
                } catch {
                    await MainActor.run {
                        self.isProcessing = false
                    }
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func resizeImage(_ image: UIImage, to maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = min(maxSize / size.width, maxSize / size.height)
        
        if ratio >= 1.0 {
            return image // No need to resize
        }
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    private func generateThumbnail(from image: UIImage) -> UIImage {
        let thumbnailSize: CGFloat = 150
        return resizeImage(image, to: thumbnailSize)
    }
    
    private func generateVideoThumbnail(from asset: AVAsset) async -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 300, height: 300)
        
        do {
            let cgImage = try await imageGenerator.image(at: .zero).image
            return UIImage(cgImage: cgImage)
        } catch {
            print("Failed to generate video thumbnail: \(error)")
            return nil
        }
    }
    
    // MARK: - File Management
    func saveToDocuments(_ media: ProcessedMedia) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = "\(media.id.uuidString).\(media.type.fileExtension)"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            try media.originalData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save media to documents: \(error)")
            return nil
        }
    }
    
    func deleteFromDocuments(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
    
    // MARK: - Permissions
    func checkPhotoLibraryPermission() async -> PHAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
    
    func checkCameraPermission() async -> AVAuthorizationStatus {
        return await AVCaptureDevice.requestAccess(for: .video) ? .authorized : .denied
    }
}

// MARK: - Processed Media Model
struct ProcessedMedia: Identifiable {
    let id: UUID
    let type: MediaType
    let originalData: Data
    let thumbnailData: Data
    let fileSize: Int
    let dimensions: CGSize
    var duration: TimeInterval?
    var originalURL: URL?
    
    var thumbnail: UIImage? {
        UIImage(data: thumbnailData)
    }
    
    var originalImage: UIImage? {
        guard type == .image else { return nil }
        return UIImage(data: originalData)
    }
}

extension MediaType {
    var fileExtension: String {
        switch self {
        case .image:
            return "jpg"
        case .video:
            return "mp4"
        case .audio:
            return "m4a"
        case .none:
            return "txt"
        }
    }
}