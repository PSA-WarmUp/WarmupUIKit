import XCTest
@testable import WarmupUIKit

/// Whether the server's own words are fit to put in front of a person. Substituting "Something
/// went wrong on our end" for every 4xx hid a workout builder rejecting unnamed sections, a feed
/// post dying in a stack overflow and a failing profile update — for weeks, because nothing on
/// screen could tell a broken server from a rejected input.
final class ServerMessageTests: XCTestCase {

    // MARK: - What gets shown

    func testAServerSentenceAboutTheUsersInputIsShownToThem() {
        XCTAssertEqual(ServerMessage.presentable("Section name is required"), "Section name is required")
        XCTAssertEqual(ServerMessage.presentable("You already follow this user"),
                       "You already follow this user")
        XCTAssertEqual(ServerMessage.presentable("  Trimmed message  "), "Trimmed message")
    }

    // MARK: - What gets hidden

    /// A 4xx body can carry an exception class or a stack frame. None of it belongs on screen, and
    /// leaking a package name tells an attacker more than it tells the client.
    func testADiagnosticIsNeverShownToAPerson() {
        XCTAssertNil(ServerMessage.presentable("java.lang.NullPointerException"))
        XCTAssertNil(ServerMessage.presentable("NullPointerException at line 42"))
        XCTAssertNil(ServerMessage.presentable("Error at com.warmup.workout.SectionService"))
        XCTAssertNil(ServerMessage.presentable("at org.springframework.web.servlet.Dispatcher"))
        XCTAssertNil(ServerMessage.presentable("SQLSTATE[23000]: integrity constraint violation"))
        XCTAssertNil(ServerMessage.presentable("JDBC connection refused"))
        XCTAssertNil(ServerMessage.presentable("org.hibernate.LazyInitializationException"))
        XCTAssertNil(ServerMessage.presentable("MongoTimeoutException"))
    }

    /// Case can't be a way past the filter — a leak spelled in caps is still a leak.
    func testADiagnosticIsRecognisedRegardlessOfCasing() {
        XCTAssertNil(ServerMessage.presentable("JAVA.LANG.IllegalStateException"))
        XCTAssertNil(ServerMessage.presentable("StackTrace follows"))
    }

    /// A bare code says nothing to a person, and a body long enough to be a dump is a dump.
    func testSomethingTooShortToBeASentenceOrLongEnoughToBeADumpIsHidden() {
        XCTAssertNil(ServerMessage.presentable("E42"))
        XCTAssertNil(ServerMessage.presentable("400"))
        XCTAssertNil(ServerMessage.presentable(String(repeating: "a", count: 201)))
        XCTAssertEqual(ServerMessage.presentable(String(repeating: "a", count: 200))?.count, 200,
                       "200 characters is still a message; 201 is a dump")
    }

    func testAnEmptyOrAbsentServerMessageFallsBackToTheGenericLine() {
        XCTAssertNil(ServerMessage.presentable(nil))
        XCTAssertNil(ServerMessage.presentable(""))
        XCTAssertNil(ServerMessage.presentable("    "))
    }

    // MARK: - Reading the raw body

    /// `APIResponse.success` is non-optional, so a 4xx that isn't our own envelope — Spring's
    /// default error page — fails to decode and takes the server's explanation with it. This is
    /// the fallback read.
    func testSpringsOwnErrorPageStillYieldsItsExplanation() {
        let body = Data("""
        {"timestamp":"2026-09-04T21:00:00.000+00:00","status":400,"error":"Bad Request",\
        "message":"Section name is required","path":"/v1/workouts"}
        """.utf8)

        XCTAssertEqual(ServerMessage.presentable(data: body, envelopeMessage: nil),
                       "Section name is required")
    }

    /// With no usable `message`, the HTTP reason phrase is still better than claiming the server
    /// is broken.
    func testTheReasonPhraseIsUsedWhenThereIsNoMessage() {
        let body = Data(#"{"status":400,"error":"Bad Request","path":"/v1/workouts"}"#.utf8)
        XCTAssertEqual(ServerMessage.presentable(data: body, envelopeMessage: nil), "Bad Request")
    }

    /// Our own envelope is the better source when it has something to say.
    func testOurOwnEnvelopeMessageWinsOverTheRawBody() {
        let body = Data(#"{"error":"Bad Request"}"#.utf8)
        XCTAssertEqual(ServerMessage.presentable(data: body, envelopeMessage: "You already follow this user"),
                       "You already follow this user")
    }

    /// A leaking envelope must not shortcut past the raw body — the safe message is still there.
    func testALeakingEnvelopeFallsThroughToTheSaferRawMessage() {
        let body = Data(#"{"message":"Section name is required"}"#.utf8)
        XCTAssertEqual(ServerMessage.presentable(data: body, envelopeMessage: "java.lang.IllegalStateException"),
                       "Section name is required")
    }

    /// A leak in the raw body is still a leak; the caller gets nil and shows its own generic line.
    func testALeakingRawBodyYieldsNothingToShow() {
        let body = Data(#"{"message":"java.lang.NullPointerException at com.warmup.Foo"}"#.utf8)
        XCTAssertNil(ServerMessage.presentable(data: body, envelopeMessage: nil))
    }

    func testAnUnreadableOrEmptyBodyYieldsNothingToShow() {
        XCTAssertNil(ServerMessage.presentable(data: Data(), envelopeMessage: nil))
        XCTAssertNil(ServerMessage.presentable(data: Data("<html>502 Bad Gateway</html>".utf8),
                                               envelopeMessage: nil))
        XCTAssertNil(ServerMessage.presentable(data: Data("{}".utf8), envelopeMessage: nil))
    }
}
