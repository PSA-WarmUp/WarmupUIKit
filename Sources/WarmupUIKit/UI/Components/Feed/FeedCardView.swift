//
//  FeedCardView.swift
//  WarmupUIKit
//
//  Main feed card component — Quiet Pro V2 design
//  Shared between trainer and client apps
//

import SwiftUI

public struct FeedCardView: View {
    public let post: FeedItem
    public let onLike: () -> Void
    public let onComment: () -> Void
    public let onMore: () -> Void
    public let onTap: () -> Void
    public var onCongrats: (() -> Void)? = nil

    public init(
        post: FeedItem,
        onLike: @escaping () -> Void,
        onComment: @escaping () -> Void,
        onMore: @escaping () -> Void,
        onTap: @escaping () -> Void,
        onCongrats: (() -> Void)? = nil
    ) {
        self.post = post
        self.onLike = onLike
        self.onComment = onComment
        self.onMore = onMore
        self.onTap = onTap
        self.onCongrats = onCongrats
    }

    public var body: some View {
        // Don't wrap the whole card in a Button. Nested Buttons in SwiftUI 17/18
        // have flaky hit-testing — taps near the Like/Comment area get eaten by
        // the outer Button at random. Instead, attach the row tap to the
        // header/content area only and let the footer's buttons handle their
        // own taps without competing.
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                FeedCardHeader(post: post, onMore: onMore)
                cardContent
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)

            FeedCardFooter(
                post: post,
                onLike: onLike,
                onComment: onComment,
                onCongrats: onCongrats
            )
        }
        .background(DS.Color.card)
        .cornerRadius(DS.Space.cardRadius)
    }

    @ViewBuilder
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: DS.Space.v8) {
            // The user's caption, rendered as a proper multi-line body (was previously only a
            // 1-line truncated header subtitle, so it read as "missing"). Shown for every post type.
            if let caption = post.displayCaption, !caption.isEmpty {
                Text(caption)
                    .font(DS.Typo.body)
                    .foregroundColor(DS.Color.text)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // The card itself has no horizontal padding — the header and each card
                    // variant pad themselves. The caption didn't, so it ran to the very edge
                    // and read as though it were clipped.
                    .padding(.horizontal, DS.Space.cardPad)
                    .padding(.bottom, DS.Space.v8)
            }

            switch post.postType {
            case .milestone:
                MilestoneCardContent(post: post)
            case .trainerShoutout:
                ShoutoutCardContent(post: post)
            case .reflection, .weeklySummary:
                // Text-only posts — the caption above IS the content.
                //
                // A weekly summary has no workout to describe: its numbers are already in the
                // sentence ("2 workouts, 150 minutes"). Falling through to the workout card
                // wrapped that sentence in a "Week in Review / Weekly Summary" header that
                // repeated it, an empty metrics band, and then the sentence again — a post
                // nested inside a post, saying one thing three times.
                EmptyView()
            default:
                if let fullCard = post.effectiveFullCard {
                    FullCardContent(post: post, card: fullCard)
                } else if let friendsCard = post.friendsCard {
                    FriendsCardContent(post: post, card: friendsCard)
                } else if let publicCard = post.publicCard {
                    PublicCardContent(post: post, card: publicCard)
                } else {
                    MinimalCardContent(post: post)
                }
            }
        }
    }
}

// MARK: - Card Header
public struct FeedCardHeader: View {
    public let post: FeedItem
    public let onMore: () -> Void

    public init(post: FeedItem, onMore: @escaping () -> Void) {
        self.post = post
        self.onMore = onMore
    }

    public var body: some View {
        HStack(spacing: DS.Space.v8) {
            // Avatar
            if let avatarUrl = post.avatarUrl, let url = URL(string: avatarUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    avatarPlaceholder
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }

            // Name, time, and optional subtitle
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(post.displayName)
                        .font(DS.Typo.bodyMedium)
                        .foregroundColor(DS.Color.text)

                    if post.author?.isTrainer == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(DS.Color.primary)
                    }

                    Text("· \(post.timeAgo)")
                        .font(DS.Typo.caption)
                        .foregroundColor(DS.Color.textSec)
                }
                // Caption moved to the card body (see FeedCardView.cardContent) so the full text
                // renders instead of a 1-line truncated header subtitle.
            }

            Spacer()

            // More button
            Button(action: onMore) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(DS.Color.textSec)
                    .frame(width: 32, height: 32)
            }
        }
        .padding(DS.Space.cardPad)
    }

    private var avatarPlaceholder: some View {
        let colors = DS.Color.avatar(for: post.displayName)
        return Circle()
            .fill(colors.bg)
            .frame(width: 40, height: 40)
            .overlay(
                Text(String(post.displayName.prefix(2)).uppercased())
                    .font(DS.Typo.calloutMedium)
                    .foregroundColor(colors.fg)
            )
    }
}

// MARK: - Card Footer
public struct FeedCardFooter: View {
    public let post: FeedItem
    public let onLike: () -> Void
    public let onComment: () -> Void
    public var onCongrats: (() -> Void)? = nil

    public init(post: FeedItem, onLike: @escaping () -> Void, onComment: @escaping () -> Void, onCongrats: (() -> Void)? = nil) {
        self.post = post
        self.onLike = onLike
        self.onComment = onComment
        self.onCongrats = onCongrats
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.v8) {
            // Engagement text + PR improvement
            HStack {
                if post.likes > 0 || post.comments > 0 {
                    HStack(spacing: DS.Space.v12) {
                        if post.likes > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: post.hasLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 12))
                                    .foregroundColor(post.hasLiked ? DS.Color.primary : DS.Color.textSec)
                                Text("\(post.likes)")
                                    .font(DS.Typo.caption)
                                    .foregroundColor(DS.Color.textSec)
                            }
                        }
                        if post.comments > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.left")
                                    .font(.system(size: 12))
                                    .foregroundColor(DS.Color.textSec)
                                Text("\(post.comments)")
                                    .font(DS.Typo.caption)
                                    .foregroundColor(DS.Color.textSec)
                            }
                        }
                    }
                } else {
                    Text("Be the first to like this")
                        .font(DS.Typo.caption)
                        .foregroundColor(DS.Color.textTer)
                }

                Spacer()

                // PR improvement label
                if let label = post.prProgression?.improvementLabel {
                    Text(label)
                        .font(DS.Typo.caption)
                        .foregroundColor(DS.Color.textSec)
                }
            }
            .padding(.horizontal, DS.Space.cardPad)

            Divider()
                .background(DS.Color.hairline)

            // Action buttons. Each button explicitly owns its hit area via
            // .contentShape(Rectangle()) and uses .borderless to avoid the
            // outer-button-eats-taps issue we used to have in this footer.
            HStack(spacing: 0) {
                Button(action: onLike) {
                    HStack(spacing: 6) {
                        Image(systemName: post.hasLiked ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(post.hasLiked ? DS.Color.primary : DS.Color.textSec)

                        Text("Like")
                            .font(DS.Typo.callout)
                            .foregroundColor(post.hasLiked ? DS.Color.primary : DS.Color.textSec)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Space.v8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)

                Button(action: onComment) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 18))
                            .foregroundColor(DS.Color.textSec)

                        Text("Comment")
                            .font(DS.Typo.callout)
                            .foregroundColor(DS.Color.textSec)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Space.v8)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)

                if let onCongrats = onCongrats, post.postType == .milestone {
                    Button(action: onCongrats) {
                        HStack(spacing: 6) {
                            Image(systemName: "hands.clap.fill")
                                .font(.system(size: 18))
                                .foregroundColor(DS.Color.warning)

                            Text("Congrats")
                                .font(DS.Typo.callout)
                                .foregroundColor(DS.Color.warning)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Space.v8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal, DS.Space.v8)
        }
        .padding(.bottom, DS.Space.v8)
    }
}

// MARK: - Milestone Card Content
public struct MilestoneCardContent: View {
    public let post: FeedItem

    public init(post: FeedItem) {
        self.post = post
    }

    public var body: some View {
        VStack(spacing: DS.Space.v16) {
            if let milestone = post.milestone {
                Circle()
                    .fill(DS.Color.warning.opacity(0.15))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: milestone.iconName)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(DS.Color.warning)
                    )

                if let title = milestone.title {
                    Text(title)
                        .font(DS.Typo.title2)
                        .foregroundColor(DS.Color.text)
                        .multilineTextAlignment(.center)
                }

                if let subtitle = milestone.subtitle {
                    Text(subtitle)
                        .font(DS.Typo.body)
                        .foregroundColor(DS.Color.textSec)
                        .multilineTextAlignment(.center)
                }
            }

            // PR Progression chart (if available)
            if let prProgression = post.prProgression,
               let points = prProgression.dataPoints, !points.isEmpty {
                PRProgressionChart(progression: prProgression)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DS.Space.cardPad)
        .padding(.vertical, DS.Space.v20)
        .background(
            LinearGradient(
                colors: [DS.Color.warningSoft, DS.Color.warningSoft],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

// MARK: - Shoutout Card Content
public struct ShoutoutCardContent: View {
    public let post: FeedItem

    public init(post: FeedItem) {
        self.post = post
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DS.Space.v12) {
            if let shoutout = post.shoutout {
                // Client being highlighted
                if let clientName = shoutout.clientName {
                    HStack(spacing: DS.Space.v8) {
                        if let avatarUrl = shoutout.clientAvatarUrl, let url = URL(string: avatarUrl) {
                            AsyncImage(url: url) { image in
                                image.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle().fill(DS.Color.cardHi)
                            }
                            .frame(width: 48, height: 48)
                            .clipShape(Circle())
                        } else {
                            let colors = DS.Color.avatar(for: clientName)
                            Circle()
                                .fill(colors.bg)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Text(String(clientName.prefix(1)).uppercased())
                                        .font(DS.Typo.headline)
                                        .foregroundColor(colors.fg)
                                )
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Shoutout to")
                                .font(DS.Typo.caption)
                                .foregroundColor(DS.Color.textSec)

                            Text(clientName)
                                .font(DS.Typo.title3)
                                .foregroundColor(DS.Color.text)
                        }

                        Spacer()

                        Image(systemName: "megaphone.fill")
                            .font(.system(size: 24))
                            .foregroundColor(DS.Color.primary)
                    }
                }

                // Message
                if let message = shoutout.message {
                    Text(message)
                        .font(DS.Typo.body)
                        .foregroundColor(DS.Color.text)
                        .padding(DS.Space.cardPad)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(DS.Color.primarySoft)
                        .cornerRadius(DS.Space.innerRadius)
                }

                // Achievements
                if let achievements = shoutout.achievements, !achievements.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DS.Space.v8) {
                            ForEach(achievements, id: \.self) { achievement in
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                    Text(achievement)
                                        .font(DS.Typo.caption)
                                }
                                .foregroundColor(DS.Color.warning)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(DS.Color.warningSoft)
                                .cornerRadius(DS.Space.smallRadius)
                            }
                        }
                    }
                }
            }
        }
        .padding(DS.Space.cardPad)
    }
}
