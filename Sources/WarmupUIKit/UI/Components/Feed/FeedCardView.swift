//
//  FeedCardView.swift
//  WarmupUIKit
//
//  Main feed card component — Quiet Pro V2 design
//  Shared between trainer and client apps
//

import SwiftUI

public struct FeedCardView: View {
    /// Opens a coach from a post's "with …" credit. Nil keeps it as plain text, which is what
    /// the trainer app rendered for months — the shared card had the name and no way to use it.
    public var onTrainerTap: ((String) -> Void)? = nil
    public let post: FeedItem
    public let onLike: () -> Void
    public let onComment: () -> Void
    public let onMore: () -> Void
    public let onTap: () -> Void
    public var onCongrats: (() -> Void)? = nil

    /// The viewer's own fold state. Ignored entirely when the poster pinned the post open.
    @State private var isCollapsed = false

    public init(
        post: FeedItem,
        onLike: @escaping () -> Void,
        onComment: @escaping () -> Void,
        onMore: @escaping () -> Void,
        onTap: @escaping () -> Void,
        onCongrats: (() -> Void)? = nil,
        onTrainerTap: ((String) -> Void)? = nil
    ) {
        self.onTrainerTap = onTrainerTap
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
                FeedCardHeader(
                    post: post,
                    onMore: onMore,
                    // The chevron only offers to fold what is currently unfolded; the summary
                    // row below is the way back open.
                    onCollapse: isFolded || post.isPinnedOpen ? nil : {
                        withAnimation(.easeInOut(duration: 0.18)) { isCollapsed = true }
                    }
                )
                if !isFolded {
                    cardContent
                }
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)

            // Outside the tap region above, so expanding a folded card can't also fire onTap.
            if isFolded {
                collapsedSummary
            }

            FeedCardFooter(
                post: post,
                onLike: onLike,
                onComment: onComment,
                onCongrats: onCongrats
            )
        }
        // dsCardSurface, not a bare fill: it carries the hairline and the light-mode shadow.
        // A white card on the #F5F5F7 page is 1.09:1, so a fill on its own has no edge at all
        // and the feed reads as one flat sheet — which is exactly why light mode looked worse
        // than dark here, where #1A1A1E on #0B0B0D is a real step on the ramp and needs no help.
        .dsCardSurface()
    }

    private var isFolded: Bool {
        isCollapsed && !post.isPinnedOpen
    }

    /// One line standing in for the folded content, so a collapsed card still says something.
    private var collapsedSummary: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { isCollapsed = false }
        } label: {
            HStack(spacing: DS.Space.v4) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                Text(post.displayWorkoutType.map { "Show \($0)" } ?? "Show post")
                    .font(DS.Typo.caption)
                Spacer()
            }
            .foregroundColor(DS.Color.textSec)
            .padding(.horizontal, DS.Space.cardPad)
            .padding(.bottom, DS.Space.v12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
                    FullCardContent(onTrainerTap: onTrainerTap, post: post, card: fullCard)
                } else if let friendsCard = post.friendsCard {
                    FriendsCardContent(onTrainerTap: onTrainerTap, post: post, card: friendsCard)
                } else if let publicCard = post.publicCard {
                    PublicCardContent(onTrainerTap: onTrainerTap, post: post, card: publicCard)
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
    /// Folds the post away. Nil hides the affordance — there is nothing to fold, or the
    /// poster pinned it open.
    public var onCollapse: (() -> Void)? = nil

    public init(post: FeedItem, onMore: @escaping () -> Void, onCollapse: (() -> Void)? = nil) {
        self.post = post
        self.onMore = onMore
        self.onCollapse = onCollapse
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

            if let onCollapse {
                Button(action: onCollapse) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DS.Color.textTer)
                        .frame(width: 28, height: 32)
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Collapse post")
            }

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

                // Who can see this. The trainer app had the field and never drew it, so a coach
                // posting to one client and a coach posting publicly looked identical.
                if let visibility = post.visibility {
                    HStack(spacing: 4) {
                        Image(systemName: visibility.iconName)
                            .font(.system(size: 11))
                        Text(visibility.displayName)
                            .font(DS.Typo.caption)
                    }
                    .foregroundColor(DS.Color.textTer)
                }
            }
            .padding(.horizontal, DS.Space.cardPad)

            if hasActions {
            Divider()
                .background(DS.Color.hairline)

            // Action buttons. Each button explicitly owns its hit area via
            // .contentShape(Rectangle()) and uses .borderless to avoid the
            // outer-button-eats-taps issue we used to have in this footer.
            HStack(spacing: 0) {
                // The server decides who may react — a post shared to a coach only, or an
                // account that blocked you, comes back with these false. Drawing the buttons
                // anyway just offers an action the API will refuse.
                if post.canLike {
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
                .accessibilityIdentifier("feedLikeButton")
                }

                if post.canComment {
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
                .accessibilityIdentifier("feedCommentButton")
                }

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
        }
        .padding(.bottom, DS.Space.v8)
    }

    /// False when the viewer may do nothing here — without this the divider and the button row
    /// still draw, leaving a hairline over an empty band.
    private var hasActions: Bool {
        post.canLike || post.canComment || (onCongrats != nil && post.postType == .milestone)
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
