//
//  AnalyticsManager.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftUI

// MARK: - Analytics Manager
class AnalyticsManager: ObservableObject {
    weak var authenticationManager: AuthenticationManager?
    
    // MARK: - Event Tracking
    func trackEvent(_ event: AnalyticsEvent) {
        // In production, this would send to analytics service
        print("📊 Analytics: \(event.name) - \(event.properties)")
    }
    
    func trackScreenView(_ screenName: String) {
        trackEvent(AnalyticsEvent(
            name: "screen_view",
            properties: ["screen_name": screenName]
        ))
    }
    
    func trackUserAction(_ action: String, properties: [String: Any] = [:]) {
        trackEvent(AnalyticsEvent(
            name: action,
            properties: properties
        ))
    }
    
    // MARK: - User Properties
    func setUserProperty(_ key: String, value: Any) {
        // In production, this would set user properties in analytics
        print("📊 User Property: \(key) = \(value)")
    }
    
    func setUserID(_ userID: String) {
        // In production, this would identify the user in analytics
        print("📊 User ID: \(userID)")
    }
}

// MARK: - Analytics Event
struct AnalyticsEvent {
    let name: String
    let properties: [String: Any]
    let timestamp: Date
    
    init(name: String, properties: [String: Any] = [:]) {
        self.name = name
        self.properties = properties
        self.timestamp = Date()
    }
}

// MARK: - Analytics Constants
enum AnalyticsConstants {
    static let userSignUp = "user_sign_up"
    static let userLogin = "user_login"
    static let momentCreated = "moment_created"
    static let momentLiked = "moment_liked"
    static let momentCommented = "moment_commented"
    static let momentShared = "moment_shared"
    static let friendRequestSent = "friend_request_sent"
    static let friendRequestAccepted = "friend_request_accepted"
    static let communityJoined = "community_joined"
    static let eventCreated = "event_created"
    static let eventJoined = "event_joined"
    static let profileUpdated = "profile_updated"
    static let settingsChanged = "settings_changed"
    static let gdprConsentGiven = "gdpr_consent_given"
    static let pushNotificationEnabled = "push_notification_enabled"
    static let pushNotificationDisabled = "push_notification_disabled"
    static let biometricAuthEnabled = "biometric_auth_enabled"
    static let biometricAuthFailed = "biometric_auth_failed"
    static let appOpened = "app_opened"
    static let appBackgrounded = "app_backgrounded"
    static let appForegrounded = "app_foregrounded"
    static let searchPerformed = "search_performed"
    static let contentFiltered = "content_filtered"
    static let errorOccurred = "error_occurred"
    static let crashReported = "crash_reported"
    static let performanceMetric = "performance_metric"
    static let networkRequest = "network_request"
    static let cacheHit = "cache_hit"
    static let cacheMiss = "cache_miss"
    static let syncCompleted = "sync_completed"
    static let syncFailed = "sync_failed"
    static let offlineMode = "offline_mode"
    static let onlineMode = "online_mode"
    static let contentReported = "content_reported"
    static let userBlocked = "user_blocked"
    static let userUnblocked = "user_unblocked"
    static let privacySettingChanged = "privacy_setting_changed"
    static let locationShared = "location_shared"
    static let locationDenied = "location_denied"
    static let cameraUsed = "camera_used"
    static let photoLibraryAccessed = "photo_library_accessed"
    static let microphoneUsed = "microphone_used"
    static let notificationReceived = "notification_received"
    static let notificationTapped = "notification_tapped"
    static let deepLinkOpened = "deep_link_opened"
    static let shareSheetOpened = "share_sheet_opened"
    static let inAppPurchase = "in_app_purchase"
    static let subscriptionStarted = "subscription_started"
    static let subscriptionCancelled = "subscription_cancelled"
    static let subscriptionRenewed = "subscription_renewed"
    static let trialStarted = "trial_started"
    static let trialEnded = "trial_ended"
    static let premiumFeatureUsed = "premium_feature_used"
    static let adViewed = "ad_viewed"
    static let adClicked = "ad_clicked"
    static let adDismissed = "ad_dismissed"
    static let adFailed = "ad_failed"
    static let adLoaded = "ad_loaded"
    static let adRequested = "ad_requested"
    static let adRevenue = "ad_revenue"
    static let userEngagement = "user_engagement"
    static let sessionStart = "session_start"
    static let sessionEnd = "session_end"
    static let sessionDuration = "session_duration"
    static let userRetention = "user_retention"
    static let userChurn = "user_churn"
    static let userReactivation = "user_reactivation"
    static let userDeactivation = "user_deactivation"
    static let userDeletion = "user_deletion"
    static let dataExport = "data_export"
    static let dataDeletion = "data_deletion"
    static let supportContacted = "support_contacted"
    static let feedbackSubmitted = "feedback_submitted"
    static let ratingSubmitted = "rating_submitted"
    static let reviewSubmitted = "review_submitted"
    static let appStoreOpened = "app_store_opened"
    static let appStoreReviewRequested = "app_store_review_requested"
    static let appStoreReviewShown = "app_store_review_shown"
    static let appStoreReviewDismissed = "app_store_review_dismissed"
    static let appStoreReviewSubmitted = "app_store_review_submitted"
    static let appStoreReviewCancelled = "app_store_review_cancelled"
    static let appStoreReviewError = "app_store_review_error"
    static let appStoreReviewSuccess = "app_store_review_success"
    static let appStoreReviewFailure = "app_store_review_failure"
    static let appStoreReviewTimeout = "app_store_review_timeout"
    static let appStoreReviewNetworkError = "app_store_review_network_error"
    static let appStoreReviewServerError = "app_store_review_server_error"
    static let appStoreReviewClientError = "app_store_review_client_error"
    static let appStoreReviewUnknownError = "app_store_review_unknown_error"
} 