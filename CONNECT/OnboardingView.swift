//
//  OnboardingView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI
import PhotosUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var container: DependencyContainer
    
    @State private var currentStep = 0
    @State private var username = ""
    @State private var displayName = ""
    @State private var email = ""
    @State private var bio = ""
    @State private var interests: [String] = []
    @State private var selectedInterest = ""
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var instagramHandle = ""
    @State private var gdprAccepted = false
    @State private var analyticsConsent = false
    @State private var isCreatingUser = false
    
    let availableInterests = [
        "Technology", "Travel", "Food", "Music", "Art", "Sports", "Photography",
        "Gaming", "Books", "Movies", "Fitness", "Nature", "Fashion", "Science",
        "Business", "Education", "Health", "Cooking", "Dancing", "Writing"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.2),
                        Color(red: 0.1, green: 0.05, blue: 0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack {
                    // Progress Bar
                    ProgressView(value: Double(currentStep + 1), total: 4)
                        .progressViewStyle(LinearProgressViewStyle())
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Content
                    TabView(selection: $currentStep) {
                        // Step 1: Welcome & Basic Info
                        Step1WelcomeView(
                            username: $username,
                            displayName: $displayName,
                            email: $email
                        )
                        .tag(0)
                        
                        // Step 2: Interests
                        Step2InterestsView(
                            interests: $interests,
                            selectedInterest: $selectedInterest,
                            availableInterests: availableInterests
                        )
                        .tag(1)
                        
                        // Step 3: Profile Photo
                        Step3ProfilePhotoView(
                            profileImage: $profileImage,
                            showImagePicker: $showImagePicker
                        )
                        .tag(2)
                        
                        // Step 4: GDPR & Instagram
                        Step4FinalStepView(
                            instagramHandle: $instagramHandle,
                            gdprAccepted: $gdprAccepted,
                            analyticsConsent: $analyticsConsent
                        )
                        .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    // Navigation Buttons
                    HStack {
                        if currentStep > 0 {
                            Button("Back") {
                                withAnimation {
                                    currentStep -= 1
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                        }
                        
                        Button(currentStep == 3 ? "Complete Setup" : "Next") {
                            if currentStep == 3 {
                                completeOnboarding()
                            } else {
                                withAnimation {
                                    currentStep += 1
                                }
                            }
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canProceed ? .white : .gray)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .disabled(!canProceed || isCreatingUser)
                        .opacity(isCreatingUser ? 0.6 : 1.0)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
    
    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !username.isEmpty && !displayName.isEmpty && !email.isEmpty
        case 1:
            return !interests.isEmpty
        case 2:
            return true // Profile photo is optional
        case 3:
            return gdprAccepted
        default:
            return false
        }
    }
    
    private func completeOnboarding() {
        guard gdprAccepted else { return }
        
        isCreatingUser = true
        
        Task {
            let user = User(
                username: username,
                displayName: displayName,
                email: email,
                bio: bio,
                interests: interests
            )
            
            // Set GDPR consent
            user.acceptGDPRTerms()
            user.analyticsConsent = analyticsConsent
            user.marketingConsent = analyticsConsent
            
            // Save user to SwiftData
            modelContext.insert(user)
            
            do {
                try modelContext.save()
                
                // Complete onboarding
                await MainActor.run {
                    authManager.completeOnboarding(user: user)
                    isCreatingUser = false
                }
            } catch {
                print("Failed to save user: \(error)")
                isCreatingUser = false
            }
        }
    }
}

// MARK: - Step 1: Welcome & Basic Info
struct Step1WelcomeView: View {
    @Binding var username: String
    @Binding var displayName: String
    @Binding var email: String
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Welcome to Connect!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Let's get you set up with your profile")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                CustomTextField(
                    title: "Username",
                    text: $username,
                    placeholder: "Choose a unique username"
                )
                
                CustomTextField(
                    title: "Display Name",
                    text: $displayName,
                    placeholder: "Your full name"
                )
                
                CustomTextField(
                    title: "Email",
                    text: $email,
                    placeholder: "your@email.com"
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Step 2: Interests
struct Step2InterestsView: View {
    @Binding var interests: [String]
    @Binding var selectedInterest: String
    let availableInterests: [String]
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("What are you into?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Select your interests to connect with like-minded people")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Selected Interests
            if !interests.isEmpty {
                FlowLayout(data: interests, spacing: 8) { interest in
                    InterestChip(
                        text: interest,
                        isSelected: true,
                        action: {
                            interests.removeAll { $0 == interest }
                        }
                    )
                }
                .padding(.horizontal)
            }
            
            // Available Interests
            ScrollView {
                FlowLayout(data: availableInterests.filter { !interests.contains($0) }, spacing: 8) { interest in
                    InterestChip(
                        text: interest,
                        isSelected: false,
                        action: {
                            if !interests.contains(interest) {
                                interests.append(interest)
                            }
                        }
                    )
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Step 3: Profile Photo
struct Step3ProfilePhotoView: View {
    @Binding var profileImage: UIImage?
    @Binding var showImagePicker: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "camera.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Add a profile photo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Help friends recognize you")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            // Profile Image Preview
            Button {
                showImagePicker = true
            } label: {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                            
                            Text("Tap to add photo")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            Button("Choose from Library") {
                showImagePicker = true
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .padding(.horizontal)
            
            Text("You can skip this step and add a photo later")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Step 4: Final Step
struct Step4FinalStepView: View {
    @Binding var instagramHandle: String
    @Binding var gdprAccepted: Bool
    @Binding var analyticsConsent: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                
                Text("Almost there!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Just a few final details")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 20) {
                CustomTextField(
                    title: "Instagram (Optional)",
                    text: $instagramHandle,
                    placeholder: "@your_instagram"
                )
                
                // GDPR Consent
                VStack(spacing: 16) {
                    HStack {
                        Button {
                            gdprAccepted.toggle()
                        } label: {
                            Image(systemName: gdprAccepted ? "checkmark.square.fill" : "square")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("I accept the Terms of Service and Privacy Policy")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text("Required to use Connect")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                    
                    HStack {
                        Button {
                            analyticsConsent.toggle()
                        } label: {
                            Image(systemName: analyticsConsent ? "checkmark.square.fill" : "square")
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Allow analytics and marketing communications")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .medium))
                            
                            Text("Optional - helps us improve Connect")
                                .foregroundColor(.white.opacity(0.6))
                                .font(.caption)
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Supporting Views
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct InterestChip: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                
                if isSelected {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                }
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? .white : .white.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout<Data, Content>: View where Data: RandomAccessCollection, Content: View, Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    init(data: Data, spacing: CGFloat = 8, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
        .frame(height: calculateHeight(in: UIScreen.main.bounds.width))
    }
    
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        return ZStack(alignment: .topLeading) {
            ForEach(Array(data.enumerated()), id: \.element) { index, item in
                content(item)
                    .padding(.trailing, spacing)
                    .padding(.bottom, spacing)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > geometry.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if index == data.count - 1 {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if index == data.count - 1 {
                            height = 0
                        }
                        return result
                    })
            }
        }
    }
    
    private func calculateHeight(in width: CGFloat) -> CGFloat {
        // Simple height calculation - you might want to make this more sophisticated
        let itemsPerRow = max(1, Int(width / 100)) // Assuming average item width of 100
        let numberOfRows = (data.count + itemsPerRow - 1) / itemsPerRow
        return CGFloat(numberOfRows) * 40 // Assuming average item height of 40
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(DependencyContainer().authenticationManager)
        .environmentObject(DependencyContainer())
} 