//
//  AuthenticationManager.swift
//  CONNECT
//
//  Created by Connect Team
//

import Foundation
import SwiftUI
import LocalAuthentication

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var authenticationError: String?
    @Published var onboardingCompleted = false
    
    private let keychain = KeychainManager()
    
    init() {
        checkAuthenticationStatus()
    }
    
    // MARK: - Authentication Status
    func checkAuthenticationStatus() {
        isLoading = true
        
        // Check if user has completed onboarding
        if let userData = keychain.getUserData() {
            self.currentUser = userData
            self.isAuthenticated = true
            self.onboardingCompleted = true
        }
        
        isLoading = false
    }
    
    // MARK: - Onboarding
    func completeOnboarding(user: User) {
        self.currentUser = user
        self.isAuthenticated = true
        self.onboardingCompleted = true
        
        // Save to keychain
        keychain.saveUserData(user)
        
        // Track analytics
        AnalyticsManager.shared.track(.userOnboardingCompleted)
    }
    
    // MARK: - Biometric Authentication
    func authenticateWithBiometrics() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            await MainActor.run {
                self.authenticationError = "Biometric authentication not available"
            }
            return false
        }
        
        do {
            let result = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access Connect"
            )
            
            await MainActor.run {
                if result {
                    self.authenticationError = nil
                }
            }
            
            return result
        } catch {
            await MainActor.run {
                self.authenticationError = error.localizedDescription
            }
            return false
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        onboardingCompleted = false
        authenticationError = nil
        
        // Clear keychain
        keychain.clearUserData()
        
        // Track analytics
        AnalyticsManager.shared.track(.userSignedOut)
    }
    
    // MARK: - Update User
    func updateCurrentUser(_ user: User) {
        self.currentUser = user
        keychain.saveUserData(user)
    }
}

// MARK: - Keychain Manager
class KeychainManager {
    private let userDataKey = "ConnectUserData"
    
    func saveUserData(_ user: User) {
        // Store basic user info to UserDefaults for demo
        // In production, use proper Keychain storage
        let userData: [String: Any] = [
            "id": user.id.uuidString,
            "username": user.username,
            "displayName": user.displayName,
            "email": user.email,
            "profilePictureURL": user.profilePictureURL ?? "",
            "bio": user.bio,
            "interests": user.interests
        ]
        UserDefaults.standard.set(userData, forKey: userDataKey)
    }
    
    func getUserData() -> User? {
        // For demo purposes, return nil to trigger onboarding
        // In production, reconstruct User from stored data
        guard let userData = UserDefaults.standard.dictionary(forKey: userDataKey),
              let idString = userData["id"] as? String,
              let id = UUID(uuidString: idString),
              let username = userData["username"] as? String,
              let displayName = userData["displayName"] as? String,
              let email = userData["email"] as? String else {
            return nil
        }
        
        // For demo, always return nil to show onboarding
        return nil
    }
    
    func clearUserData() {
        UserDefaults.standard.removeObject(forKey: userDataKey)
    }
}

// MARK: - Analytics Manager
class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    weak var authenticationManager: AuthenticationManager?
    
    enum Event {
        case userOnboardingCompleted
        case userSignedOut
        case momentCreated
        case friendRequestSent
    }
    
    func track(_ event: Event) {
        // Analytics tracking implementation
        print("Analytics: \(event)")
    }
} 