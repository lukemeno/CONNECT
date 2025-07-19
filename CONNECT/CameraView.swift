//
//  CameraView.swift
//  CONNECT
//
//  Created by Connect Team
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.capturedImage = image
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
}

// MARK: - Custom Camera View with Controls
struct CustomCameraView: View {
    @Binding var capturedImage: UIImage?
    @Binding var isPresented: Bool
    @StateObject private var cameraManager = CameraManager()
    
    var body: some View {
        ZStack {
            // Camera Preview
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()
            
            // Camera Controls Overlay
            VStack {
                // Top Controls
                HStack {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                    
                    Button {
                        cameraManager.toggleFlash()
                    } label: {
                        Image(systemName: cameraManager.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Bottom Controls
                HStack {
                    // Gallery Button
                    Button {
                        // Open gallery
                    } label: {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white, lineWidth: 2)
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                                    .font(.title3)
                            }
                    }
                    
                    Spacer()
                    
                    // Capture Button
                    Button {
                        cameraManager.capturePhoto { image in
                            self.capturedImage = image
                            self.isPresented = false
                        }
                    } label: {
                        Circle()
                            .fill(.white)
                            .frame(width: 80, height: 80)
                            .overlay {
                                Circle()
                                    .stroke(.gray, lineWidth: 2)
                                    .frame(width: 70, height: 70)
                            }
                    }
                    
                    Spacer()
                    
                    // Switch Camera Button
                    Button {
                        cameraManager.switchCamera()
                    } label: {
                        Image(systemName: "camera.rotate")
                            .foregroundColor(.white)
                            .font(.title2)
                            .frame(width: 50, height: 50)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            cameraManager.checkPermissions()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}

// MARK: - Camera Preview
struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.frame
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// MARK: - Camera Manager
@MainActor
class CameraManager: ObservableObject {
    nonisolated let session = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput?
    private var photoOutput = AVCapturePhotoOutput()
    private var currentDevice: AVCaptureDevice?
    
    @Published var isFlashOn = false
    @Published var isAuthorized = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            isAuthorized = false
            alertMessage = "Camera access is required to take photos"
            showAlert = true
        @unknown default:
            break
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        // Add video input
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return
        }
        
        currentDevice = device
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: device)
            if let deviceInput = deviceInput, session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
        } catch {
            print("Failed to create device input: \(error)")
        }
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .quality
        }
        
        session.commitConfiguration()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        
        if isFlashOn && currentDevice?.hasFlash == true {
            settings.flashMode = .on
        } else {
            settings.flashMode = .off
        }
        
        let delegate = PhotoCaptureDelegate(completion: completion)
        photoOutput.capturePhoto(with: settings, delegate: delegate)
    }
    
    func switchCamera() {
        session.beginConfiguration()
        
        // Remove current input
        if let deviceInput = deviceInput {
            session.removeInput(deviceInput)
        }
        
        // Switch to opposite camera
        let newPosition: AVCaptureDevice.Position = currentDevice?.position == .back ? .front : .back
        
        guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition) else {
            session.commitConfiguration()
            return
        }
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice)
            if let deviceInput = deviceInput, session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
                currentDevice = newDevice
            }
        } catch {
            print("Failed to switch camera: \(error)")
        }
        
        session.commitConfiguration()
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.stopRunning()
            }
        }
    }
}

// MARK: - Photo Capture Delegate
class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completion = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Photo capture error: \(error)")
            completion(nil)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completion(nil)
            return
        }
        
        completion(image)
    }
}

#Preview {
    CustomCameraView(capturedImage: .constant(nil), isPresented: .constant(true))
}