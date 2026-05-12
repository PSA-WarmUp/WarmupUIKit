//
//  DSSkeleton.swift
//  WarmupUIKit
//
//  Loading-state placeholders with shimmer.
//

import SwiftUI
import UIKit

/// Self-contained shimmer modifier so DSSkeleton doesn't depend on which
/// `shimmer()` extension is in scope at the call site.
private struct DSShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.15),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 1.5)
                    .offset(x: phase * geo.size.width * 1.5)
                }
                .mask(content)
            )
            .onAppear {
                guard !UIAccessibility.isReduceMotionEnabled else { return }
                withAnimation(
                    .linear(duration: 1.4).repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

public struct DSSkeleton: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    public init(width: CGFloat? = nil, height: CGFloat = 12, cornerRadius: CGFloat = 6) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(DS.Color.cardHi)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .modifier(DSShimmerModifier())
            .accessibilityHidden(true)
    }
}

public struct DSSkeletonCard: View {
    let lines: Int
    let showAvatar: Bool

    public init(lines: Int = 3, showAvatar: Bool = false) {
        self.lines = lines
        self.showAvatar = showAvatar
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showAvatar {
                HStack(spacing: 12) {
                    Circle()
                        .fill(DS.Color.cardHi)
                        .frame(width: 40, height: 40)
                        .modifier(DSShimmerModifier())
                    VStack(alignment: .leading, spacing: 6) {
                        DSSkeleton(width: 120, height: 12)
                        DSSkeleton(width: 80, height: 10)
                    }
                    Spacer()
                }
            }
            ForEach(0..<lines, id: \.self) { i in
                DSSkeleton(
                    width: i == lines - 1 ? 200 : nil,
                    height: 12
                )
            }
        }
        .padding(DS.Space.cardPad)
        .background(
            RoundedRectangle(cornerRadius: DS.Space.cardRadius, style: .continuous)
                .fill(DS.Color.card)
        )
        .accessibilityLabel("Loading")
    }
}

public struct DSSkeletonList: View {
    let count: Int
    let lines: Int
    let showAvatar: Bool

    public init(count: Int = 3, lines: Int = 2, showAvatar: Bool = true) {
        self.count = count
        self.lines = lines
        self.showAvatar = showAvatar
    }

    public var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<count, id: \.self) { _ in
                DSSkeletonCard(lines: lines, showAvatar: showAvatar)
            }
        }
        .accessibilityLabel("Loading content")
    }
}
