//
//  CircularProgressView.swift
//  WarmupUIKit
//
//  A circular progress indicator with customizable styling
//

import SwiftUI

/// A circular progress indicator with customizable styling
public struct CircularProgressView: View {
    /// Progress value from 0.0 to 1.0
    public let progress: Double

    /// Line width for the progress stroke
    public var lineWidth: CGFloat

    /// Color for the progress stroke (defaults to primary)
    public var progressColor: Color

    /// Color for the background track
    public var trackColor: Color

    /// Whether to show the percentage label in the center
    public var showLabel: Bool

    /// Animation for progress changes
    public var animated: Bool

    public init(
        progress: Double,
        lineWidth: CGFloat = 12,
        progressColor: Color = DynamicTheme.Colors.primary,
        trackColor: Color = DynamicTheme.Colors.border,
        showLabel: Bool = false,
        animated: Bool = true
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.progressColor = progressColor
        self.trackColor = trackColor
        self.showLabel = showLabel
        self.animated = animated
    }

    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(animated ? DynamicTheme.Animations.standard : nil, value: progress)

            // Optional percentage label
            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(DynamicTheme.Typography.headline)
                    .foregroundColor(DynamicTheme.Colors.text)
            }
        }
    }
}

// MARK: - Preset Sizes

public extension CircularProgressView {
    /// Small size (32pt) for inline use
    static func small(progress: Double, color: Color = DynamicTheme.Colors.primary) -> some View {
        CircularProgressView(progress: progress, lineWidth: 4, progressColor: color)
            .frame(width: 32, height: 32)
    }

    /// Medium size (64pt) for cards
    static func medium(progress: Double, color: Color = DynamicTheme.Colors.primary, showLabel: Bool = true) -> some View {
        CircularProgressView(progress: progress, lineWidth: 8, progressColor: color, showLabel: showLabel)
            .frame(width: 64, height: 64)
    }

    /// Large size (120pt) for featured displays
    static func large(progress: Double, color: Color = DynamicTheme.Colors.primary, showLabel: Bool = true) -> some View {
        CircularProgressView(progress: progress, lineWidth: 12, progressColor: color, showLabel: showLabel)
            .frame(width: 120, height: 120)
    }
}

// MARK: - Gradient Variant

/// Gradient variant for more visual richness
public struct GradientCircularProgressView: View {
    public let progress: Double
    public var lineWidth: CGFloat
    public var gradient: LinearGradient
    public var trackColor: Color
    public var showLabel: Bool
    public var animated: Bool

    public init(
        progress: Double,
        lineWidth: CGFloat = 12,
        gradient: LinearGradient = DynamicTheme.Colors.primaryGradient,
        trackColor: Color = DynamicTheme.Colors.border,
        showLabel: Bool = false,
        animated: Bool = true
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.gradient = gradient
        self.trackColor = trackColor
        self.showLabel = showLabel
        self.animated = animated
    }

    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            // Progress arc with gradient
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(animated ? DynamicTheme.Animations.standard : nil, value: progress)

            // Optional percentage label
            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(DynamicTheme.Typography.headline)
                    .foregroundColor(DynamicTheme.Colors.text)
            }
        }
    }
}

#Preview {
    VStack(spacing: DynamicTheme.Spacing.xl) {
        HStack(spacing: DynamicTheme.Spacing.lg) {
            CircularProgressView.small(progress: 0.3)
            CircularProgressView.small(progress: 0.6, color: DynamicTheme.Colors.success)
            CircularProgressView.small(progress: 0.9, color: DynamicTheme.Colors.secondary)
        }

        HStack(spacing: DynamicTheme.Spacing.lg) {
            CircularProgressView.medium(progress: 0.45)
            CircularProgressView.medium(progress: 0.75, color: DynamicTheme.Colors.success)
        }

        CircularProgressView.large(progress: 0.85)

        GradientCircularProgressView(progress: 0.7, showLabel: true)
            .frame(width: 100, height: 100)
    }
    .padding()
}
