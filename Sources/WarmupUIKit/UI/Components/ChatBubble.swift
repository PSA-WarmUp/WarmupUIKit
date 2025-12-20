//
//  ChatBubble.swift
//  WarmupUIKit
//
//  Reusable chat bubble component for messaging interfaces
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Chat Message Protocol

/// Protocol for any message that can be displayed in a ChatBubble
public protocol ChatMessageDisplayable {
    var id: String { get }
    var content: String { get }
    var isFromCurrentUser: Bool { get }
    var timestamp: Date { get }
}

// MARK: - Default Chat Message

/// Default implementation of ChatMessageDisplayable
public struct ChatMessage: ChatMessageDisplayable, Identifiable {
    public let id: String
    public let content: String
    public let isFromCurrentUser: Bool
    public let timestamp: Date

    public init(
        id: String = UUID().uuidString,
        content: String,
        isFromCurrentUser: Bool,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.isFromCurrentUser = isFromCurrentUser
        self.timestamp = timestamp
    }
}

// MARK: - Chat Bubble Style

/// Defines the visual style of a chat bubble
public enum ChatBubbleStyle {
    /// Standard messaging bubble (rounded corners, directional)
    case message
    /// AI assistant bubble (different corner radius pattern)
    case assistant
    /// Minimal bubble with subtle styling
    case minimal
}

// MARK: - Chat Bubble

/// A reusable chat bubble component that displays messages with proper styling.
///
/// Usage:
/// ```swift
/// ChatBubble(message: myMessage)
/// ChatBubble(content: "Hello!", isFromCurrentUser: true)
/// ```
public struct ChatBubble<Message: ChatMessageDisplayable>: View {

    // MARK: - Properties

    let message: Message
    let style: ChatBubbleStyle
    let showTimestamp: Bool
    let userBubbleColor: Color
    let otherBubbleColor: Color
    let userTextColor: Color
    let otherTextColor: Color
    let maxWidthRatio: CGFloat

    // MARK: - Initialization

    /// Creates a chat bubble from a ChatMessageDisplayable
    public init(
        message: Message,
        style: ChatBubbleStyle = .message,
        showTimestamp: Bool = true,
        userBubbleColor: Color = DynamicTheme.Colors.primary,
        otherBubbleColor: Color = DynamicTheme.Colors.bubbleBackground,
        userTextColor: Color = .white,
        otherTextColor: Color = DynamicTheme.Colors.text,
        maxWidthRatio: CGFloat = 0.75
    ) {
        self.message = message
        self.style = style
        self.showTimestamp = showTimestamp
        self.userBubbleColor = userBubbleColor
        self.otherBubbleColor = otherBubbleColor
        self.userTextColor = userTextColor
        self.otherTextColor = otherTextColor
        self.maxWidthRatio = maxWidthRatio
    }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .bottom, spacing: DynamicTheme.Spacing.xs) {
            if message.isFromCurrentUser {
                Spacer(minLength: UIScreen.main.bounds.width * (1 - maxWidthRatio))
            }

            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 2) {
                bubbleContent

                if showTimestamp {
                    timestampView
                }
            }

            if !message.isFromCurrentUser {
                Spacer(minLength: UIScreen.main.bounds.width * (1 - maxWidthRatio))
            }
        }
        .padding(.horizontal, DynamicTheme.Spacing.md)
    }

    // MARK: - Subviews

    private var bubbleContent: some View {
        Text(message.content)
            .font(DynamicTheme.Typography.body)
            .foregroundColor(message.isFromCurrentUser ? userTextColor : otherTextColor)
            .padding(.horizontal, DynamicTheme.Spacing.md)
            .padding(.vertical, DynamicTheme.Spacing.sm)
            .background(message.isFromCurrentUser ? userBubbleColor : otherBubbleColor)
            .clipShape(bubbleShape)
    }

    private var bubbleShape: some Shape {
        BubbleShape(
            isFromCurrentUser: message.isFromCurrentUser,
            style: style
        )
    }

    private var timestampView: some View {
        Text(formattedTimestamp)
            .font(DynamicTheme.Typography.caption)
            .foregroundColor(DynamicTheme.Colors.textTertiary)
    }

    private var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: message.timestamp)
    }
}

// MARK: - Convenience Initializer

extension ChatBubble where Message == ChatMessage {
    /// Creates a chat bubble with raw content
    public init(
        content: String,
        isFromCurrentUser: Bool,
        timestamp: Date = Date(),
        style: ChatBubbleStyle = .message,
        showTimestamp: Bool = true
    ) {
        self.init(
            message: ChatMessage(
                content: content,
                isFromCurrentUser: isFromCurrentUser,
                timestamp: timestamp
            ),
            style: style,
            showTimestamp: showTimestamp
        )
    }
}

#if canImport(UIKit)
// MARK: - Bubble Shape

/// Custom shape for chat bubbles with directional corners
public struct BubbleShape: Shape {
    let isFromCurrentUser: Bool
    let style: ChatBubbleStyle

    public init(isFromCurrentUser: Bool, style: ChatBubbleStyle = .message) {
        self.isFromCurrentUser = isFromCurrentUser
        self.style = style
    }

    public func path(in rect: CGRect) -> Path {
        let radius: CGFloat = style == .minimal ? 12 : 16

        // Determine which corners should be rounded
        let corners: UIRectCorner
        switch style {
        case .message:
            corners = isFromCurrentUser
                ? [.topLeft, .topRight, .bottomLeft]
                : [.topLeft, .topRight, .bottomRight]
        case .assistant:
            corners = isFromCurrentUser
                ? [.topLeft, .topRight, .bottomLeft]
                : [.topLeft, .topRight, .bottomRight]
        case .minimal:
            corners = .allCorners
        }

        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        return Path(path.cgPath)
    }
}

// MARK: - Rounded Corner Helper

/// Shape helper for custom corner radius on specific corners
public struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    public init(radius: CGFloat = .infinity, corners: UIRectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - View Extension

public extension View {
    /// Clips the view to a rounded rectangle with specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}
#endif

// MARK: - Previews

#Preview("Chat Bubbles") {
    VStack(spacing: 16) {
        ChatBubble(
            content: "Hey! How's your workout going?",
            isFromCurrentUser: false
        )

        ChatBubble(
            content: "Great! Just finished my last set 💪",
            isFromCurrentUser: true
        )

        ChatBubble(
            content: "That's awesome! Keep up the good work.",
            isFromCurrentUser: false,
            style: .assistant
        )
    }
    .padding()
}
