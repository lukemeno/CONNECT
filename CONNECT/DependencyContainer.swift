//
//  DependencyContainer.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftUI

@MainActor
class DependencyContainer: ObservableObject {
    
    // MARK: - Core Services
    lazy var authenticationManager = AuthenticationManager()
    lazy var momentCreationService = MomentCreationService()
    lazy var socialConnectionService = SocialConnectionService()
    lazy var feedAlgorithmService = FeedAlgorithmService()
    lazy var userDiscoveryService = UserDiscoveryService()
    lazy var notificationService = NotificationService()
    lazy var mediaProcessingService = MediaProcessingService()
    lazy var analyticsManager = AnalyticsManager()
    
    init() {
        setupDependencies()
    }
    
    private func setupDependencies() {
        // Inject dependencies between services
        momentCreationService.mediaProcessingService = mediaProcessingService
        socialConnectionService.notificationService = notificationService
        analyticsManager.authenticationManager = authenticationManager
    }
}

// MARK: - Environment Key
struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue = DependencyContainer()
}

extension EnvironmentValues {
    var dependencyContainer: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
} 