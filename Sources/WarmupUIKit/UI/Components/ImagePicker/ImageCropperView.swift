//
//  ImageCropperView.swift
//  WarmupUIKit
//
//  Image cropping and adjustment view for profile photos
//

import SwiftUI

public struct ImageCropperView: View {
    public let image: UIImage
    public let onCrop: (UIImage) -> Void
    public let onCancel: () -> Void

    // Gesture states
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var imageLoaded = false

    // Crop circle size (for profile photos)
    private let cropCircleSize: CGFloat = 280

    public init(
        image: UIImage,
        onCrop: @escaping (UIImage) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.image = image
        self.onCrop = onCrop
        self.onCancel = onCancel
    }

    public var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Dark background
                    Color.black.ignoresSafeArea()

                    // Image with gestures
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                        .scaleEffect(scale)
                        .offset(offset)
                        .onAppear {
                            imageLoaded = true
                        }
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        // Limit scale between 1x and 5x
                                        scale = min(max(scale * delta, 1.0), 5.0)
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        // Ensure image covers crop area
                                        withAnimation(.spring(response: 0.3)) {
                                            constrainOffset(in: geometry)
                                        }
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                        // Constrain offset to keep image in crop area
                                        withAnimation(.spring(response: 0.3)) {
                                            constrainOffset(in: geometry)
                                            lastOffset = offset
                                        }
                                    }
                            )
                        )

                    // Crop overlay with circle cutout
                    CropOverlay(cropSize: cropCircleSize)
                        .allowsHitTesting(false)

                    // Instructions
                    VStack {
                        Text("Pinch to zoom, drag to move")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 60)

                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                    .foregroundColor(.white)
                }

                ToolbarItem(placement: .principal) {
                    Text("Adjust Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        cropImage()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(DynamicTheme.Colors.primary)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    /// Constrain offset so image always covers the crop circle
    private func constrainOffset(in geometry: GeometryProxy) {
        let imageSize = calculateScaledImageSize(in: geometry)

        // Calculate the maximum allowed offset
        let maxOffsetX = max(0, (imageSize.width - cropCircleSize) / 2)
        let maxOffsetY = max(0, (imageSize.height - cropCircleSize) / 2)

        // Constrain the offset
        offset.width = min(max(offset.width, -maxOffsetX), maxOffsetX)
        offset.height = min(max(offset.height, -maxOffsetY), maxOffsetY)
    }

    /// Calculate the scaled image size
    private func calculateScaledImageSize(in geometry: GeometryProxy) -> CGSize {
        let imageAspect = image.size.width / image.size.height
        let screenAspect = geometry.size.width / geometry.size.height

        var baseSize: CGSize
        if imageAspect > screenAspect {
            // Image is wider - height fills screen
            let height = geometry.size.height
            let width = height * imageAspect
            baseSize = CGSize(width: width, height: height)
        } else {
            // Image is taller - width fills screen
            let width = geometry.size.width
            let height = width / imageAspect
            baseSize = CGSize(width: width, height: height)
        }

        return CGSize(
            width: baseSize.width * scale,
            height: baseSize.height * scale
        )
    }

    /// Crop the image to the circular area
    private func cropImage() {
        // Get the main screen's scale and geometry
        let screenSize = UIScreen.main.bounds.size

        // Calculate the image's display properties
        let imageAspect = image.size.width / image.size.height
        let screenAspect = screenSize.width / screenSize.height

        var displaySize: CGSize
        if imageAspect > screenAspect {
            let height = screenSize.height
            let width = height * imageAspect
            displaySize = CGSize(width: width, height: height)
        } else {
            let width = screenSize.width
            let height = width / imageAspect
            displaySize = CGSize(width: width, height: height)
        }

        // Apply scale
        displaySize.width *= scale
        displaySize.height *= scale

        // Calculate the crop rect in image coordinates
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 2

        // The crop circle's position in screen coordinates
        let cropCenterX = centerX - offset.width
        let cropCenterY = centerY - offset.height

        // Convert to image coordinates (relative to scaled displayed image)
        let imageOriginX = (screenSize.width - displaySize.width) / 2
        let imageOriginY = (screenSize.height - displaySize.height) / 2

        let relativeX = (cropCenterX - imageOriginX) / displaySize.width
        let relativeY = (cropCenterY - imageOriginY) / displaySize.height

        let relativeCropSize = cropCircleSize / displaySize.width

        // Calculate crop rect in original image coordinates
        let cropX = relativeX * image.size.width - (relativeCropSize * image.size.width / 2)
        let cropY = relativeY * image.size.height - (relativeCropSize * image.size.width / 2)
        let cropSize = relativeCropSize * image.size.width

        // Create the crop rect
        var cropRect = CGRect(
            x: cropX,
            y: cropY,
            width: cropSize,
            height: cropSize
        )

        // Clamp to image bounds
        cropRect = cropRect.intersection(CGRect(origin: .zero, size: image.size))

        // Perform the crop
        guard let cgImage = image.cgImage,
              let croppedCGImage = cgImage.cropping(to: cropRect) else {
            onCrop(image) // Fallback to original
            return
        }

        // Create circular mask
        let outputSize = CGSize(width: 500, height: 500) // Output size for profile
        let renderer = UIGraphicsImageRenderer(size: outputSize)

        let circularImage = renderer.image { _ in
            // Create circular clipping path
            let circlePath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: outputSize))
            circlePath.addClip()

            // Draw the cropped image
            let croppedImage = UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
            croppedImage.draw(in: CGRect(origin: .zero, size: outputSize))
        }

        onCrop(circularImage)
    }
}

/// Overlay with circular cutout for cropping
public struct CropOverlay: View {
    public let cropSize: CGFloat

    public init(cropSize: CGFloat) {
        self.cropSize = cropSize
    }

    public var body: some View {
        GeometryReader { _ in
            ZStack {
                // Semi-transparent background
                Rectangle()
                    .fill(Color.black.opacity(0.6))

                // Clear circle in the center
                Circle()
                    .frame(width: cropSize, height: cropSize)
                    .blendMode(.destinationOut)

                // Circle border
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: cropSize, height: cropSize)
            }
            .compositingGroup()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ImageCropperView_Previews: PreviewProvider {
    static var previews: some View {
        ImageCropperView(
            image: UIImage(systemName: "person.fill")!,
            onCrop: { _ in },
            onCancel: {}
        )
    }
}
#endif
