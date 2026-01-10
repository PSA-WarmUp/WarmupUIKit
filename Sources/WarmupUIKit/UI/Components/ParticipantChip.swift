//
//  ParticipantChip.swift
//  WarmupUIKit
//
//  Chip component for displaying selected participants
//

import SwiftUI

// MARK: - Participant Chip

/// A chip view for displaying a selected participant with optional remove action.
/// Used in group creation flows to show selected members.
///
/// Usage:
/// ```swift
/// ParticipantChip(name: "John Doe", avatarUrl: nil) {
///     // Handle remove
/// }
/// ```
public struct ParticipantChip: View {

    // MARK: - Properties

    let name: String
    let avatarUrl: String?
    let onRemove: (() -> Void)?

    // MARK: - Initialization

    public init(
        name: String,
        avatarUrl: String? = nil,
        onRemove: (() -> Void)? = nil
    ) {
        self.name = name
        self.avatarUrl = avatarUrl
        self.onRemove = onRemove
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: DynamicTheme.Spacing.xs) {
            // Small avatar
            avatarView

            // First name only for compact display
            Text(firstName)
                .font(DynamicTheme.Typography.caption)
                .foregroundColor(DynamicTheme.Colors.text)
                .lineLimit(1)

            // Remove button
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(DynamicTheme.Colors.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.leading, DynamicTheme.Spacing.xs)
        .padding(.trailing, onRemove != nil ? DynamicTheme.Spacing.xs : DynamicTheme.Spacing.sm)
        .padding(.vertical, DynamicTheme.Spacing.xs)
        .background(DynamicTheme.Colors.bubbleBackground)
        .clipShape(Capsule())
    }

    // MARK: - Subviews

    private var avatarView: some View {
        Group {
            if let urlString = avatarUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        initialsCircle
                    }
                }
            } else {
                initialsCircle
            }
        }
        .frame(width: 24, height: 24)
        .clipShape(Circle())
    }

    private var initialsCircle: some View {
        Circle()
            .fill(DynamicTheme.Colors.primary.opacity(0.2))
            .overlay(
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(DynamicTheme.Colors.primary)
            )
    }

    // MARK: - Helpers

    private var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }
}

// MARK: - Participant Chips Row

/// Horizontally scrolling row of participant chips
public struct ParticipantChipsRow: View {

    public struct Participant: Identifiable {
        public let id: String
        public let name: String
        public let avatarUrl: String?

        public init(id: String, name: String, avatarUrl: String? = nil) {
            self.id = id
            self.name = name
            self.avatarUrl = avatarUrl
        }
    }

    let participants: [Participant]
    let onRemove: ((Participant) -> Void)?

    public init(
        participants: [Participant],
        onRemove: ((Participant) -> Void)? = nil
    ) {
        self.participants = participants
        self.onRemove = onRemove
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DynamicTheme.Spacing.sm) {
                ForEach(participants) { participant in
                    ParticipantChip(
                        name: participant.name,
                        avatarUrl: participant.avatarUrl
                    ) {
                        onRemove?(participant)
                    }
                }
            }
            .padding(.horizontal, DynamicTheme.Spacing.md)
        }
    }
}

// MARK: - Previews

#Preview("Participant Chips") {
    VStack(spacing: 24) {
        Text("Individual Chips")
            .font(.headline)

        HStack(spacing: 8) {
            ParticipantChip(name: "John Doe") {
                print("Remove John")
            }

            ParticipantChip(name: "Jane Smith", avatarUrl: nil) {
                print("Remove Jane")
            }

            ParticipantChip(name: "Alex", avatarUrl: nil, onRemove: nil)
        }

        Text("Chips Row")
            .font(.headline)

        ParticipantChipsRow(
            participants: [
                .init(id: "1", name: "John Doe"),
                .init(id: "2", name: "Jane Smith"),
                .init(id: "3", name: "Alex Johnson"),
                .init(id: "4", name: "Maria Garcia"),
                .init(id: "5", name: "David Lee")
            ]
        ) { participant in
            print("Remove \(participant.name)")
        }
    }
    .padding()
}
