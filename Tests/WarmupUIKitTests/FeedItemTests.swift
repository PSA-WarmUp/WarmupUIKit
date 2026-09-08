import XCTest
@testable import WarmupUIKit

/// The feed post model. Everything here decides what a card shows, and `withLikeState` rebuilds
/// the whole post from scratch on every tap of the heart — so a field left out of it disappears
/// from the screen the moment someone likes the post.
final class FeedItemTests: XCTestCase {

    // MARK: - Fixtures

    /// Every field populated with a distinguishable value, so a dropped one is visible rather
    /// than hidden behind a matching default.
    private func fullyPopulatedItem() -> FeedItem {
        FeedItem(
            id: "post-1",
            author: AuthorInfo(userId: "user-1", displayName: "Finley", avatarUrl: "https://x/a.png",
                               isTrainer: false, isCurrentUser: true),
            postType: .workoutSummary,
            perspective: .coach,
            visibility: .friends,
            createdAt: "2026-09-04T21:00:00Z",
            displayMode: "PINNED",
            publicCard: nil,
            friendsCard: nil,
            fullCard: nil,
            milestone: nil,
            shoutout: nil,
            workoutType: "Upper Body",
            title: "Push Day",
            programName: "Hypertrophy Block 2",
            workoutLabel: "Week 3 · Day 1",
            trainerName: "Coach Sam",
            trainerId: "trainer-9",
            durationMinutes: 62,
            totalSets: 18,
            totalReps: 144,
            totalVolume: 12_450,
            volumeUnit: "lbs",
            averageRpe: 7.5,
            personalRecordsCount: 2,
            prFlags: ["BENCH_PRESS"],
            trainerNotes: "Great bar speed",
            clientReflection: "Felt strong",
            caption: "New bench PR",
            likeCount: 4,
            commentCount: 1,
            viewerLiked: false,
            viewerCanComment: true,
            viewerCanLike: true,
            availableActions: ["LIKE", "COMMENT"],
            prProgression: PRProgressionDto(exerciseName: "Bench Press", durationLabel: "12 WEEKS",
                                            dataPoints: [PRDataPoint(weekIndex: 0, value: 185, isPR: false)],
                                            currentValue: 205, unit: "lb",
                                            improvementLabel: "+20 lb · new 1RM"),
            linkedWorkoutId: "workout-7"
        )
    }

    private func minimalItem(
        displayMode: String? = nil,
        publicCard: PublicCardDto? = nil,
        friendsCard: FriendsCardDto? = nil,
        fullCard: FullCardDto? = nil,
        workoutType: String? = nil,
        title: String? = nil,
        caption: String? = nil,
        viewerCanLike: Bool? = nil,
        viewerCanComment: Bool? = nil
    ) -> FeedItem {
        FeedItem(
            id: "post-min", author: nil, postType: .workout, perspective: nil, visibility: nil,
            createdAt: nil, displayMode: displayMode,
            publicCard: publicCard, friendsCard: friendsCard, fullCard: fullCard,
            milestone: nil, shoutout: nil,
            workoutType: workoutType, title: title, programName: nil, workoutLabel: nil,
            durationMinutes: nil, totalSets: nil, totalReps: nil, totalVolume: nil, volumeUnit: nil,
            averageRpe: nil, personalRecordsCount: nil, prFlags: nil, trainerNotes: nil,
            clientReflection: nil, caption: caption,
            likeCount: nil, commentCount: nil, viewerLiked: nil,
            viewerCanComment: viewerCanComment, viewerCanLike: viewerCanLike,
            availableActions: nil, linkedWorkoutId: nil
        )
    }

    private func card(caption: String?) -> FullCardDto {
        FullCardDto(workoutType: nil, durationMinutes: nil, caloriesBurned: nil, avgHeartRate: nil,
                    totalVolume: nil, volumeUnit: nil, distanceMiles: nil, pace: nil,
                    programName: nil, workoutLabel: nil, exercises: nil, rpe: nil,
                    trainerNotes: nil, clientReflection: nil, caption: caption, prFlags: nil,
                    timeAgo: nil, totalSets: nil, totalReps: nil, personalRecordsCount: nil,
                    averageRpe: nil)
    }

    // MARK: - withLikeState

    /// The coach's id was missing from this rebuild, so tapping the heart turned the post's coach
    /// credit from a tappable link back into plain text until the next feed load.
    func testLikingAPostKeepsItsCoachCreditTappable() {
        let liked = fullyPopulatedItem().withLikeState(liked: true, likeCount: 5)

        XCTAssertEqual(liked.trainerId, "trainer-9")
        XCTAssertEqual(liked.trainerName, "Coach Sam")
    }

    /// A pinned post that quietly became collapsible on a like would fold itself away under the
    /// reader's next tap.
    func testLikingAPostKeepsItPinnedOpen() {
        let liked = fullyPopulatedItem().withLikeState(liked: true, likeCount: 5)

        XCTAssertEqual(liked.displayMode, "PINNED")
        XCTAssertTrue(liked.isPinnedOpen)
    }

    /// The whole post is rebuilt field by field, so this asserts the whole post. Anything added to
    /// `FeedItem` and forgotten in `withLikeState` fails here rather than on someone's screen.
    func testLikingAPostChangesOnlyTheHeartAndTheCount() {
        let original = fullyPopulatedItem()
        let liked = original.withLikeState(liked: true, likeCount: 5)

        XCTAssertTrue(liked.hasLiked, "the tap itself")
        XCTAssertEqual(liked.likes, 5, "the count that came back")

        XCTAssertEqual(liked.id, original.id)
        XCTAssertEqual(liked.author?.userId, original.author?.userId)
        XCTAssertEqual(liked.author?.displayName, original.author?.displayName)
        XCTAssertEqual(liked.author?.avatarUrl, original.author?.avatarUrl)
        XCTAssertEqual(liked.author?.isCurrentUser, original.author?.isCurrentUser)
        XCTAssertEqual(liked.postType, original.postType)
        XCTAssertEqual(liked.perspective, original.perspective)
        XCTAssertEqual(liked.visibility, original.visibility)
        XCTAssertEqual(liked.createdAt, original.createdAt)
        XCTAssertEqual(liked.displayMode, original.displayMode)
        XCTAssertEqual(liked.workoutType, original.workoutType)
        XCTAssertEqual(liked.title, original.title)
        XCTAssertEqual(liked.programName, original.programName)
        XCTAssertEqual(liked.workoutLabel, original.workoutLabel)
        XCTAssertEqual(liked.trainerName, original.trainerName)
        XCTAssertEqual(liked.trainerId, original.trainerId)
        XCTAssertEqual(liked.durationMinutes, original.durationMinutes)
        XCTAssertEqual(liked.totalSets, original.totalSets)
        XCTAssertEqual(liked.totalReps, original.totalReps)
        XCTAssertEqual(liked.totalVolume, original.totalVolume)
        XCTAssertEqual(liked.volumeUnit, original.volumeUnit)
        XCTAssertEqual(liked.averageRpe, original.averageRpe)
        XCTAssertEqual(liked.personalRecordsCount, original.personalRecordsCount)
        XCTAssertEqual(liked.prFlags, original.prFlags)
        XCTAssertEqual(liked.trainerNotes, original.trainerNotes)
        XCTAssertEqual(liked.clientReflection, original.clientReflection)
        XCTAssertEqual(liked.caption, original.caption)
        XCTAssertEqual(liked.commentCount, original.commentCount)
        XCTAssertEqual(liked.viewerCanComment, original.viewerCanComment)
        XCTAssertEqual(liked.viewerCanLike, original.viewerCanLike)
        XCTAssertEqual(liked.availableActions, original.availableActions)
        XCTAssertEqual(liked.linkedWorkoutId, original.linkedWorkoutId)
        XCTAssertEqual(liked.prProgression?.exerciseName, original.prProgression?.exerciseName)
        XCTAssertEqual(liked.prProgression?.currentValue, original.prProgression?.currentValue)
        XCTAssertEqual(liked.prProgression?.dataPoints?.count, original.prProgression?.dataPoints?.count)
    }

    /// Unliking is the same rebuild in reverse; it must not be the path that loses a field.
    func testUnlikingAPostAlsoKeepsEveryOtherField() {
        let unliked = fullyPopulatedItem().withLikeState(liked: false, likeCount: 3)

        XCTAssertFalse(unliked.hasLiked)
        XCTAssertEqual(unliked.likes, 3)
        XCTAssertEqual(unliked.trainerId, "trainer-9")
        XCTAssertEqual(unliked.linkedWorkoutId, "workout-7")
    }

    // MARK: - Engagement permissions

    /// The backend omits these on posts that predate the fields. Defaulting to "not allowed" would
    /// grey out the heart on the entire back catalogue.
    func testAPostThatSaysNothingAboutPermissionsStillAllowsLikingAndCommenting() {
        let item = minimalItem()
        XCTAssertTrue(item.canLike)
        XCTAssertTrue(item.canComment)
    }

    func testAPostThatForbidsEngagementIsRespected() {
        let item = minimalItem(viewerCanLike: false, viewerCanComment: false)
        XCTAssertFalse(item.canLike)
        XCTAssertFalse(item.canComment)
    }

    func testAPostWithNoEngagementYetReadsAsZeroRatherThanUnknown() {
        let item = minimalItem()
        XCTAssertEqual(item.likes, 0)
        XCTAssertEqual(item.comments, 0)
        XCTAssertFalse(item.hasLiked)
        XCTAssertFalse(item.isOwnPost)
        XCTAssertEqual(item.displayName, "Unknown")
        XCTAssertNil(item.avatarUrl)
    }

    // MARK: - isPinnedOpen

    /// Pinning is the poster's call. Posts made before the field existed carry no mode and must
    /// read as collapsible rather than pinning the whole back catalogue open.
    func testOnlyAnExplicitlyPinnedPostRefusesToCollapse() {
        XCTAssertTrue(minimalItem(displayMode: "PINNED").isPinnedOpen)
        XCTAssertTrue(minimalItem(displayMode: "pinned").isPinnedOpen)
        XCTAssertFalse(minimalItem(displayMode: "COLLAPSIBLE").isPinnedOpen)
        XCTAssertFalse(minimalItem(displayMode: nil).isPinnedOpen)
        XCTAssertFalse(minimalItem(displayMode: "").isPinnedOpen)
    }

    // MARK: - displayCaption

    /// The public card's caption is sanitised server-side. Preferring it meant the author read
    /// back a stripped version of their own words — or nothing, when sanitising emptied it.
    func testTheAuthorSeesTheirOwnWordsNotTheSanitisedCopy() {
        let item = minimalItem(publicCard: PublicCardDto(workoutType: nil, durationMinutes: nil,
                                                          caloriesBurned: nil, avgHeartRate: nil,
                                                          timeAgo: nil, caption: "sanitised",
                                                          totalSets: nil, totalReps: nil,
                                                          personalRecordsCount: nil),
                               fullCard: card(caption: "program: hypertrophy, felt great"))
        XCTAssertEqual(item.displayCaption, "program: hypertrophy, felt great")
    }

    /// Sanitising can leave whitespace behind. A blank caption is an absent caption, so the
    /// fallback has to keep going instead of stopping on an empty string.
    func testABlankedOutCaptionFallsThroughInsteadOfShowingNothing() {
        let item = minimalItem(fullCard: card(caption: "   \n  "), caption: "New bench PR")
        XCTAssertEqual(item.displayCaption, "New bench PR")
    }

    func testAPostWithNoCaptionAnywhereHasNoCaption() {
        XCTAssertNil(minimalItem().displayCaption)
        XCTAssertNil(minimalItem(fullCard: card(caption: "  "), caption: "").displayCaption)
    }

    func testATopLevelCaptionIsUsedWhenNoCardCarriesOne() {
        XCTAssertEqual(minimalItem(caption: "Felt strong").displayCaption, "Felt strong")
    }

    // MARK: - synthesizedFullCard / effectiveFullCard

    /// The backend sometimes sends workout data at the top level with no card at all. Without
    /// this the post renders as an empty card.
    func testAPostWithOnlyTopLevelWorkoutDataStillRendersAsAFullCard() {
        let item = minimalItem(workoutType: "Upper Body")
        let synthesized = item.synthesizedFullCard

        XCTAssertNotNil(synthesized)
        XCTAssertEqual(synthesized?.workoutType, "Upper Body")
        XCTAssertNotNil(item.effectiveFullCard)
    }

    /// With no workout type the title is the only name the card has.
    func testTheTitleStandsInForAMissingWorkoutType() {
        XCTAssertEqual(minimalItem(title: "Push Day").synthesizedFullCard?.workoutType, "Push Day")
    }

    /// Synthesising on top of a real card would overwrite the server's richer copy with a
    /// reconstruction built from whatever happened to be at the top level.
    func testARealCardIsNeverOverwrittenByASynthesizedOne() {
        let real = card(caption: "real")
        let item = minimalItem(fullCard: real, workoutType: "Upper Body")

        XCTAssertNil(item.synthesizedFullCard)
        XCTAssertEqual(item.effectiveFullCard?.caption, "real")

        XCTAssertNil(minimalItem(publicCard: PublicCardDto(workoutType: "Upper Body", durationMinutes: nil,
                                                           caloriesBurned: nil, avgHeartRate: nil,
                                                           timeAgo: nil, caption: nil, totalSets: nil,
                                                           totalReps: nil, personalRecordsCount: nil),
                                 workoutType: "Upper Body").synthesizedFullCard)
    }

    /// A post with nothing workout-shaped in it (a bare reflection) must not manufacture an empty
    /// stats card full of blanks.
    func testAPostWithNoWorkoutDataSynthesizesNothing() {
        XCTAssertNil(minimalItem(caption: "rest day").synthesizedFullCard)
        XCTAssertNil(minimalItem(caption: "rest day").effectiveFullCard)
    }

    // MARK: - PageInfo

    /// Infinite scroll stops here. Getting it wrong either strands the reader on page one or
    /// requests a page that does not exist forever.
    func testMorePagesAreOfferedOnlyWhileSomeRemain() {
        XCTAssertTrue(PageInfo(page: 0, size: 20, totalElements: 60, totalPages: 3).hasMore)
        XCTAssertTrue(PageInfo(page: 1, size: 20, totalElements: 60, totalPages: 3).hasMore)
        XCTAssertFalse(PageInfo(page: 2, size: 20, totalElements: 60, totalPages: 3).hasMore,
                       "the last page is page totalPages - 1")
        XCTAssertFalse(PageInfo(page: 0, size: 20, totalElements: 0, totalPages: 0).hasMore)
        XCTAssertFalse(PageInfo(page: nil, size: nil, totalElements: nil, totalPages: nil).hasMore)
    }

    // MARK: - AuthorInfo decoding

    /// The backend names the avatar field two different ways depending on the endpoint. Reading
    /// only one of them leaves half the feed with placeholder initials.
    func testAnAuthorAvatarIsFoundUnderEitherNameTheBackendUses() throws {
        let decoder = JSONDecoder()

        let modern = try decoder.decode(AuthorInfo.self, from: Data(
            #"{"userId":"u1","displayName":"Finley","avatarUrl":"https://x/a.png"}"#.utf8))
        XCTAssertEqual(modern.avatarUrl, "https://x/a.png")

        let legacy = try decoder.decode(AuthorInfo.self, from: Data(
            #"{"userId":"u1","displayName":"Finley","profileImageUrl":"https://x/b.png"}"#.utf8))
        XCTAssertEqual(legacy.avatarUrl, "https://x/b.png")

        let neither = try decoder.decode(AuthorInfo.self, from: Data(#"{"userId":"u1"}"#.utf8))
        XCTAssertNil(neither.avatarUrl)
    }

    // MARK: - PostType

    /// The backend sends WORKOUT and WORKOUT_SUMMARY interchangeably; a card that only recognises
    /// one of them renders the other as a generic post.
    func testBothSpellingsOfAWorkoutPostAreTreatedAsWorkouts() {
        XCTAssertTrue(PostType.workout.isWorkout)
        XCTAssertTrue(PostType.workoutSummary.isWorkout)
        XCTAssertEqual(PostType.workout.displayName, PostType.workoutSummary.displayName)
        XCTAssertFalse(PostType.milestone.isWorkout)
        XCTAssertFalse(PostType.reflection.isWorkout)
    }
}
