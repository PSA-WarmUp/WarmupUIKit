//
//  ParticipantRowView.swift
//  WarmupUIKit
//
//  Row component for displaying group participants
//

import SwiftUI

// MARK: - Participant Row View

/// A row view for displaying a group participant with role badge and actions.
/// Used in group info views to list members.
///
/// Usage:
/// ```swift
/// ParticipantRowView(
///     participant: participant,
///     isCurrentUser: false,
///     canRemove: true
/// ) {
///     // Handle remove
/// }
/// ```
public struct ParticipantRowView: View {

    // MARK: - Properties

    let participant: GroupParticipant
    let isCurrentUser: Bool
    let canRemove: Bool
    let onRemove: (() -> Void)?

    // MARK: - Initialization

    public init(
        participant: GroupParticipant,
        isCurrentUser: Bool = false,
        canRemove: Bool = false,
        onRemove: (() -> Void)? = nil
    ) {
        self.participant = participant
        self.isCurrentUser = isCurrentUser
        self.canRemove = canRemove
        self.onRemove = onRemove
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: DynamicTheme.Spacing.md) {
            // Avatar
            AvatarView(
                url: participant.profileImageUrl,
                size: .medium
            )

            // Name and role info
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: DynamicTheme.Spacing.xs) {
                    Text(participant.name)
                        .font(DynamicTheme.Typography.bodyMedium)
                        .foregroundColor(DynamicTheme.Colors.text)

                    if isCurrentUser {
                        Text("(You)")
                            .font(DynamicTheme.Typography.caption)
                            .foregroundColor(DynamicTheme.Colors.textTertiary)
                    }
                }

                HStack(spacing: DynamicTheme.Spacing.xs) {
                    // Role badge
                    roleBadge

                    // Trainer indicator
                    if participant.isTrainer {
                        trainerBadge
                    }
                }
            }

            Spacer()

            // Remove button (for admins to remove members)
            if canRemove && !isCurrentUser {
                Button(action: { onRemove?() }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(DynamicTheme.Colors.error)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, DynamicTheme.Spacing.xs)
        .contentShape(Rectangle())
    }

    // MARK: - Subviews

    private var roleBadge: some View {
        Text(participant.isAdmin ? "Admin" : "Member")
            .font(DynamicTheme.Typography.micro)
            .foregroundColor(participant.isAdmin ? DynamicTheme.Colors.primary : DynamicTheme.Colors.textSecondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(participant.isAdmin ? DynamicTheme.Colors.primary.opacity(0.15) : DynamicTheme.Colors.bubbleBackground)
            )
    }

    private var trainerBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.system(size: 8))
            Text("Trainer")
                .font(DynamicTheme.Typography.micro)
        }
        .foregroundColor(DynamicTheme.Colors.warning)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            Capsule()
                .fill(DynamicTheme.Colors.warning.opacity(0.15))
        )
    }
}

// MARK: - Selectable Participant Row

/// A variant of ParticipantRowView with selection state for adding participants
public struct SelectableParticipantRow: View {

    // MARK: - Properties

    let id: String
    let name: String
    let avatarUrl: String?
    let subtitle: String?
    let isSelected: Bool
    let onToggle: () -> Void

    // MARK: - Initialization

    public init(
        id: String,
        name: String,
        avatarUrl: String? = nil,
        subtitle: String? = nil,
        isSelected: Bool,
        onToggle: @escaping () -> Void
    ) {
        self.id = id
        self.name = name
        self.avatarUrl = avatarUrl
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.onToggle = onToggle
    }

    // MARK: - Body

    public var body: some View {
        Button(action: onToggle) {
            HStack(spacing: DynamicTheme.Spacing.md) {
                // Avatar
                AvatarView(
                    url: avatarUrl,
                    size: .medium
                )

                // Name and subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(DynamicTheme.Typography.bodyMedium)
                        .foregroundColor(DynamicTheme.Colors.text)

                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(DynamicTheme.Typography.caption)
                            .foregroundColor(DynamicTheme.Colors.textSecondary)
                    }
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? DynamicTheme.Colors.primary : DynamicTheme.Colors.textTertiary)
            }
            .padding(.vertical, DynamicTheme.Spacing.xs)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Participant Rows") {
    VStack(spacing: 0) {
        Text("Participant Row Views")
            .font(.headline)
            .padding()

        List {
            Section("Group Members") {
                ParticipantRowView(
                    participant: GroupParticipant(
                        id: "1",
                        name: "John Trainer",
                        profileImageUrl: nil,
                        role: "TRAINER",
                        groupRole: .admin,
                        joinedAt: nil
                    ),
                    isCurrentUser: true,
                    canRemove: false
                )

                ParticipantRowView(
                    participant: GroupParticipant(
                        id: "2",
                        name: "Jane Client",
                        profileImageUrl: nil,
                        role: "CLIENT",
                        groupRole: .member,
                        joinedAt: nil
                    ),
                    isCurrentUser: false,
                    canRemove: true
                ) {
                    print("Remove Jane")
                }

                ParticipantRowView(
                    participant: GroupParticipant(
                        id: "3",
                        name: "Alex Member",
                        profileImageUrl: nil,
                        role: "CLIENT",
                        groupRole: .member,
                        joinedAt: nil
                    ),
                    isCurrentUser: false,
                    canRemove: true
                ) {
                    print("Remove Alex")
                }
            }

            Section("Selectable (Add Participants)") {
                SelectableParticipantRow(
                    id: "4",
                    name: "Sarah Wilson",
                    subtitle: "Connected client",
                    isSelected: true
                ) {
                    print("Toggle Sarah")
                }

                SelectableParticipantRow(
                    id: "5",
                    name: "Mike Brown",
                    subtitle: "Connected client",
                    isSelected: false
                ) {
                    print("Toggle Mike")
                }
            }
        }
    }
}
