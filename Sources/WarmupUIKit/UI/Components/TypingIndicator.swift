//
//  TypingIndicator.swift
//  WarmupUIKit
//
//  Animated typing indicator for chat and messaging interfaces
//

import SwiftUI

/// An animated typing indicator showing three bouncing dots.
/// Commonly used in chat interfaces to show when someone is typing.
///
/// Usage:
/// ```swift
/// TypingIndicator()
/// TypingIndicator(dotColor: .blue, dotSize: 10)
/// ```
public struct TypingIndicator: View {

    // MARK: - Configuration

    let dotColor: Color
    let dotSize: CGFloat
    let spacing: CGFloat
    let animationDuration: Double

    // MARK: - State

    @State private var animationOffset: CGFloat = 0

    // MARK: - Initialization

    /// Creates a typing indicator with customizable appearance
    /// - Parameters:
    ///   - dotColor: Color of the dots (default: textSecondary at 60% opacity)
    ///   - dotSize: Size of each dot (default: 8)
    ///   - spacing: Spacing between dots (default: 4)
    ///   - animationDuration: Duration of one bounce cycle (default: 0.5)
    public init(
        dotColor: Color = DynamicTheme.Colors.textSecondary.opacity(0.6),
        dotSize: CGFloat = 8,
        spacing: CGFloat = 4,
        animationDuration: Double = 0.5
    ) {
        self.dotColor = dotColor
        self.dotSize = dotSize
        self.spacing = spacing
        self.animationDuration = animationDuration
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(dotColor)
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: animationOffset)
                    .animation(
                        Animation.easeInOut(duration: animationDuration)
                            .repeatForever()
                            .delay(Double(index) * 0.15),
                        value: animationOffset
                    )
            }
        }
        .onAppear {
            animationOffset = -dotSize
        }
    }
}

// MARK: - Typing Indicator Bubble

/// A chat bubble containing a typing indicator.
/// Use this when you want a complete bubble appearance.
public struct TypingIndicatorBubble: View {

    let bubbleColor: Color
    let shadowOpacity: Double

    public init(
        bubbleColor: Color = DynamicTheme.Colors.bubbleBackground,
        shadowOpacity: Double = 0.05
    ) {
        self.bubbleColor = bubbleColor
        self.shadowOpacity = shadowOpacity
    }

    public var body: some View {
        HStack {
            HStack(spacing: DynamicTheme.Spacing.sm) {
                TypingIndicator()
            }
            .padding(.horizontal, DynamicTheme.Spacing.md)
            .padding(.vertical, DynamicTheme.Spacing.sm)
            .background(bubbleColor)
            .cornerRadius(DynamicTheme.Radius.medium)
            .shadow(
                color: Color.black.opacity(shadowOpacity),
                radius: 2,
                x: 0,
                y: 1
            )

            Spacer()
        }
    }
}

// MARK: - Previews

#Preview("Typing Indicator") {
    VStack(spacing: 20) {
        TypingIndicator()

        TypingIndicator(dotColor: .blue, dotSize: 10)

        TypingIndicatorBubble()
    }
    .padding()
}
