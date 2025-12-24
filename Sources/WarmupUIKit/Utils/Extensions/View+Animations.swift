//
//  View+Animations.swift
//  WarmupUIKit
//
//  Micro-interaction and animation modifiers for enhanced UX
//

import SwiftUI

// MARK: - Theme Helper Extensions

public extension View {
    /// Apply theme shadow to a view
    func applyThemeShadow(_ shadow: DynamicTheme.Shadows.Shadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }

    /// Card style with updated UX: softer shadows, continuous corners
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.xl, style: .continuous)
                    .fill(DynamicTheme.Colors.cardBackground)
                    .applyThemeShadow(DynamicTheme.Shadows.card)
            )
    }

    /// Enhanced card style with padding included for convenience
    func enhancedCardStyle() -> some View {
        self
            .padding(DynamicTheme.Spacing.card)
            .background(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.xl, style: .continuous)
                    .fill(DynamicTheme.Colors.cardBackground)
                    .applyThemeShadow(DynamicTheme.Shadows.card)
            )
    }

    /// Surface style with updated UX: continuous corners
    func surfaceStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.xl, style: .continuous)
                    .fill(DynamicTheme.Colors.surface)
                    .applyThemeShadow(DynamicTheme.Shadows.medium)
            )
    }

    /// Continuous corner radius modifier for smoother iOS-like corners
    func continuousCornerRadius(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// Section spacing modifier for consistent vertical spacing between sections
    func sectionSpacing() -> some View {
        self.padding(.bottom, DynamicTheme.Spacing.section)
    }
}

// MARK: - Shimmer Loading Effect

public struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    public func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(isActive ? 0.3 : 0),
                        Color.white.opacity(0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 400 - 200)
                .animation(
                    isActive ?
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false) :
                    nil,
                    value: phase
                )
            )
            .onAppear {
                if isActive {
                    phase = 1
                }
            }
    }
}

public extension View {
    /// Apply shimmer loading effect
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
}

// MARK: - Micro-interaction Modifiers

public extension View {
    /// Bounce animation on tap - great for buttons and cards
    func bounceOnTap(scale: CGFloat = 0.95) -> some View {
        self.modifier(BounceOnTapModifier(scale: scale))
    }

    /// Spring scale effect for interactive elements
    func springScale(_ isPressed: Bool, pressedScale: CGFloat = 0.96) -> some View {
        self
            .scaleEffect(isPressed ? pressedScale : 1.0)
            .animation(DynamicTheme.Animations.spring, value: isPressed)
    }

    /// Fade in animation when view appears
    func fadeInOnAppear(delay: Double = 0) -> some View {
        self.modifier(FadeInModifier(delay: delay))
    }

    /// Slide up and fade in animation
    func slideUpOnAppear(delay: Double = 0) -> some View {
        self.modifier(SlideUpModifier(delay: delay))
    }

    /// Subtle highlight effect on tap
    func highlightOnTap() -> some View {
        self.modifier(HighlightOnTapModifier())
    }

    /// Apply staggered animation to list items
    func staggeredAnimation(index: Int, baseDelay: Double = 0.05) -> some View {
        self.modifier(SlideUpModifier(delay: Double(index) * baseDelay))
    }

    /// Press events handler for custom press feedback
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Animation Modifier Implementations

public struct BounceOnTapModifier: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false

    public func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(DynamicTheme.Animations.spring, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

public struct FadeInModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    public func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(DynamicTheme.Animations.standard.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

public struct SlideUpModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    public func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(DynamicTheme.Animations.spring.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

public struct HighlightOnTapModifier: ViewModifier {
    @State private var isPressed = false

    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: DynamicTheme.Radius.medium, style: .continuous)
                    .fill(DynamicTheme.Colors.primary.opacity(isPressed ? 0.1 : 0))
            )
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(DynamicTheme.Animations.quick) { isPressed = true }
                    }
                    .onEnded { _ in
                        withAnimation(DynamicTheme.Animations.quick) { isPressed = false }
                    }
            )
    }
}
