//
//  ConnectError.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation

// MARK: - Connect Error Types
enum ConnectError: LocalizedError {
    case authenticationFailed(String)
    case userNotFound
    case invalidData
    case networkError(String)
    case permissionDenied
    case biometricNotAvailable
    case onboardingIncomplete
    case contentCreationFailed(String)
    case socialConnectionFailed(String)
    case gdprConsentRequired
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .userNotFound:
            return "User not found. Please complete onboarding."
        case .invalidData:
            return "Invalid data provided."
        case .networkError(let message):
            return "Network error: \(message)"
        case .permissionDenied:
            return "Permission denied. Please check your settings."
        case .biometricNotAvailable:
            return "Biometric authentication is not available on this device."
        case .onboardingIncomplete:
            return "Please complete the onboarding process."
        case .contentCreationFailed(let message):
            return "Failed to create content: \(message)"
        case .socialConnectionFailed(let message):
            return "Social connection failed: \(message)"
        case .gdprConsentRequired:
            return "GDPR consent is required to continue."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .authenticationFailed:
            return "Please try again or contact support."
        case .userNotFound:
            return "Complete the onboarding process to create your profile."
        case .invalidData:
            return "Please check your input and try again."
        case .networkError:
            return "Check your internet connection and try again."
        case .permissionDenied:
            return "Grant the required permissions in Settings."
        case .biometricNotAvailable:
            return "Use alternative authentication methods."
        case .onboardingIncomplete:
            return "Complete all onboarding steps."
        case .contentCreationFailed:
            return "Try creating your content again."
        case .socialConnectionFailed:
            return "Check your connection and try again."
        case .gdprConsentRequired:
            return "Accept the terms and privacy policy to continue."
        }
    }
}

// MARK: - Error Handler
class ErrorHandler: ObservableObject {
    @Published var currentError: ConnectError?
    @Published var showError = false
    
    func handle(_ error: Error) {
        if let connectError = error as? ConnectError {
            self.currentError = connectError
        } else {
            self.currentError = .networkError(error.localizedDescription)
        }
        self.showError = true
    }
    
    func clearError() {
        currentError = nil
        showError = false
    }
} 