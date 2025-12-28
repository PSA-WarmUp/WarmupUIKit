//
//  ProfilePhotoPicker.swift
//  WarmupUIKit
//
//  Unified profile photo picker with camera, library, and cropping
//

import SwiftUI
import PhotosUI

/// State for the photo picker flow
public enum PhotoPickerState: Identifiable {
    case camera
    case cropper(UIImage)

    public var id: String {
        switch self {
        case .camera: return "camera"
        case .cropper: return "cropper"
        }
    }
}

/// Complete profile photo picker with camera, photo library, and cropping
public struct ProfilePhotoPicker: View {
    @Binding public var isPresented: Bool
    public let currentImageUrl: String?
    public let onImageSelected: (UIImage) -> Void
    public let onRemovePhoto: (() -> Void)?

    @State private var pickerState: PhotoPickerState?
    @State private var showPhotoLibrary = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    public init(
        isPresented: Binding<Bool>,
        currentImageUrl: String?,
        onImageSelected: @escaping (UIImage) -> Void,
        onRemovePhoto: (() -> Void)? = nil
    ) {
        self._isPresented = isPresented
        self.currentImageUrl = currentImageUrl
        self.onImageSelected = onImageSelected
        self.onRemovePhoto = onRemovePhoto
    }

    public var body: some View {
        EmptyView()
            .confirmationDialog("Change Profile Photo", isPresented: $isPresented, titleVisibility: .visible) {
                // Camera option (only if available)
                if isCameraAvailable() {
                    Button("Take Photo") {
                        pickerState = .camera
                    }
                }

                Button("Choose from Library") {
                    showPhotoLibrary = true
                }

                // Remove photo option (only if there's an existing photo)
                if let url = currentImageUrl, !url.isEmpty {
                    Button("Remove Photo", role: .destructive) {
                        onRemovePhoto?()
                    }
                }

                Button("Cancel", role: .cancel) {}
            }
            .fullScreenCover(item: $pickerState) { state in
                switch state {
                case .camera:
                    CameraPickerWrapper(
                        onImageCaptured: { image in
                            let fixedImage = image.fixedOrientation()
                            pickerState = .cropper(fixedImage)
                        },
                        onCancel: {
                            pickerState = nil
                        }
                    )

                case .cropper(let image):
                    ImageCropperView(
                        image: image,
                        onCrop: { croppedImage in
                            pickerState = nil
                            onImageSelected(croppedImage)
                        },
                        onCancel: {
                            pickerState = nil
                        }
                    )
                }
            }
            .photosPicker(isPresented: $showPhotoLibrary, selection: $selectedPhotoItem, matching: .images)
            .onChange(of: selectedPhotoItem) { newItem in
                if let newItem = newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            await MainActor.run {
                                let fixedImage = image.fixedOrientation()
                                pickerState = .cropper(fixedImage)
                            }
                        }
                        selectedPhotoItem = nil
                    }
                }
            }
    }
}

/// Wrapper for camera that handles its own presentation
public struct CameraPickerWrapper: View {
    public let onImageCaptured: (UIImage) -> Void
    public let onCancel: () -> Void

    public init(
        onImageCaptured: @escaping (UIImage) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onImageCaptured = onImageCaptured
        self.onCancel = onCancel
    }

    public var body: some View {
        CameraViewController(
            onImageCaptured: onImageCaptured,
            onCancel: onCancel
        )
        .ignoresSafeArea()
    }
}

/// UIKit camera view controller wrapper
public struct CameraViewController: UIViewControllerRepresentable {
    public let onImageCaptured: (UIImage) -> Void
    public let onCancel: () -> Void

    public init(
        onImageCaptured: @escaping (UIImage) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onImageCaptured = onImageCaptured
        self.onCancel = onCancel
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(onImageCaptured: onImageCaptured, onCancel: onCancel)
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImageCaptured: (UIImage) -> Void
        let onCancel: () -> Void

        init(onImageCaptured: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onImageCaptured = onImageCaptured
            self.onCancel = onCancel
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onImageCaptured(image)
            } else {
                onCancel()
            }
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
        }
    }
}

// MARK: - UIImage Orientation Fix

public extension UIImage {
    /// Fixes the orientation of the image to be upright
    func fixedOrientation() -> UIImage {
        // If orientation is already correct, return self
        guard imageOrientation != .up else { return self }

        // Use UIGraphicsImageRenderer for simpler, more reliable results
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let fixedImage = renderer.image { _ in
            self.draw(at: .zero)
        }

        return fixedImage
    }
}

/// A modifier version for easier use
public struct ProfilePhotoPickerModifier: ViewModifier {
    @Binding var isPresented: Bool
    let currentImageUrl: String?
    let onImageSelected: (UIImage) -> Void
    let onRemovePhoto: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .background(
                ProfilePhotoPicker(
                    isPresented: $isPresented,
                    currentImageUrl: currentImageUrl,
                    onImageSelected: onImageSelected,
                    onRemovePhoto: onRemovePhoto
                )
            )
    }
}

public extension View {
    /// Add profile photo picker functionality to any view
    func profilePhotoPicker(
        isPresented: Binding<Bool>,
        currentImageUrl: String?,
        onImageSelected: @escaping (UIImage) -> Void,
        onRemovePhoto: (() -> Void)? = nil
    ) -> some View {
        self.modifier(
            ProfilePhotoPickerModifier(
                isPresented: isPresented,
                currentImageUrl: currentImageUrl,
                onImageSelected: onImageSelected,
                onRemovePhoto: onRemovePhoto
            )
        )
    }
}
