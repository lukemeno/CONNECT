# 🔗 CONNECT - iOS Social Media App

A comprehensive social networking platform built with **SwiftUI** and **SwiftData** for iOS 18.5+.

![iOS](https://img.shields.io/badge/iOS-18.5+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0+-green.svg)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

## ✨ Features

### 🚀 Core Social Features
- **Moments**: Create and share text, photo, and video posts
- **Social Connections**: Send/receive friend requests and build your network
- **Engagement**: Like, comment, and react with 6 different emoji types
- **Discovery**: Find new users based on interests, location, and popularity
- **Privacy Controls**: Granular privacy settings for posts and profile

### 📱 Modern User Experience
- **4-Step Onboarding**: Welcome → Profile Setup → Photo → GDPR Consent
- **Personalized Feed**: AI-powered content algorithm
- **Rich Content Creation**: Photos, locations, feelings, activities, hashtags
- **Real-time Notifications**: Push notifications for interactions
- **Beautiful UI**: Modern SwiftUI interface with smooth animations

### 🔒 Privacy & Security
- **GDPR Compliant**: Built-in consent tracking and privacy controls
- **Biometric Authentication**: Face ID and Touch ID support
- **Content Moderation**: Automated content filtering system
- **Data Protection**: Secure data handling with CloudKit encryption

## 🏗️ Architecture

### 📊 Data Models (SwiftData)
- **User**: Profile management with GDPR compliance
- **Moment**: Posts with media, privacy, and engagement
- **Comment**: Nested comments and replies system
- **Reaction**: 6 emoji reaction types
- **FriendRequest**: Connection management
- **Community**: Groups and community features
- **Event**: Meetups and event management
- **Location**: Location services and tagging

### 🔧 Service Layer
- **AuthenticationManager**: User authentication and session management
- **MomentCreationService**: Content creation and media processing
- **SocialConnectionService**: Friend requests and connections
- **FeedAlgorithmService**: Personalized content algorithm
- **UserDiscoveryService**: User discovery and search
- **NotificationService**: Push notifications and alerts
- **MediaProcessingService**: Image and video processing
- **AnalyticsManager**: Usage tracking and insights

### 🎨 UI Components
- **RootView**: Authentication flow controller
- **OnboardingView**: 4-step user onboarding
- **ContentView**: Main tab navigation
- **FeedView**: Personalized content feed
- **EnhancedCreateMomentView**: Rich content creation
- **UserDiscoveryView**: User discovery with filters
- **ProfileView**: User profiles and settings
- **NotificationsView**: Notification center
- **CommentsView**: Comments and replies

## 🚀 Getting Started

### Prerequisites
- **Xcode 15.0+**
- **iOS 18.5+** deployment target
- **Apple Developer Account** (for CloudKit and push notifications)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/lukemeno/CONNECT.git
   cd CONNECT
   ```

2. **Open in Xcode**
   ```bash
   open CONNECT.xcodeproj
   ```

3. **Configure CloudKit**
   - Enable CloudKit capability in your Apple Developer account
   - Update the CloudKit container identifier in `CONNECT.entitlements`
   - Configure CloudKit schema to match SwiftData models

4. **Set up Push Notifications**
   - Configure push notification certificates in Apple Developer Portal
   - Update the app identifier and push notification settings

5. **Build and Run**
   - Select your target device or simulator
   - Build and run the project (`Cmd+R`)

## 📱 Usage

### First Launch
1. **Splash Screen**: Animated Connect logo
2. **Welcome**: Introduction and biometric setup option
3. **Onboarding**: 4-step profile creation process
4. **Main App**: Full social media experience

### Core Workflows
- **Create Moments**: Tap the + button to share content
- **Discover Users**: Use the Discover tab to find new connections
- **Manage Profile**: Edit your profile in the Profile tab
- **Stay Updated**: Check notifications for interactions

## 🛠️ Development

### Project Structure
```
CONNECT/
├── Models/              # SwiftData models
├── Services/            # Business logic layer
├── Views/               # SwiftUI views
├── Resources/           # Assets and configurations
└── Supporting Files/    # App configuration
```

### Key Technologies
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Core Data successor for data persistence
- **CloudKit**: iCloud integration for data sync
- **Combine**: Reactive programming framework
- **AVFoundation**: Media capture and processing
- **UserNotifications**: Push notification support

### Contributing
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Acknowledgments

- Built with ❤️ using **SwiftUI** and **SwiftData**
- Inspired by modern social media platforms
- Designed with privacy and user experience in mind

## 📞 Support

For support, email connect-support@example.com or create an issue in this repository.

---

**Built with SwiftUI 🚀 | Made for iOS 📱 | Privacy First 🔒** 