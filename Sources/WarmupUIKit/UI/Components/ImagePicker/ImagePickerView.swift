//
//  ImagePickerView.swift
//  WarmupUIKit
//
//  Camera and Photo Library image picker with UIImagePickerController
//

import SwiftUI
import UIKit

/// Source type for image picker
public enum ImagePickerSource {
    case camera
    case photoLibrary
}

/// UIImagePickerController wrapper for SwiftUI
public struct ImagePickerView: UIViewControllerRepresentable {
    public let sourceType: ImagePickerSource
    public let onImageSelected: (UIImage) -> Void
    public let onCancel: () -> Void

    public init(
        sourceType: ImagePickerSource,
        onImageSelected: @escaping (UIImage) -> Void,
        onCancel: @escaping () -> Void = {}
    ) {
        self.sourceType = sourceType
        self.onImageSelected = onImageSelected
        self.onCancel = onCancel
    }

    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false // We'll use our custom cropper

        switch sourceType {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
                picker.cameraCaptureMode = .photo
            } else {
                // Fallback to photo library if camera not available
                picker.sourceType = .photoLibrary
            }
        case .photoLibrary:
            picker.sourceType = .photoLibrary
        }

        return picker
    }

    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            } else {
                parent.onCancel()
            }
        }

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
        }
    }
}

/// Check if camera is available on device
public func isCameraAvailable() -> Bool {
    UIImagePickerController.isSourceTypeAvailable(.camera)
}
