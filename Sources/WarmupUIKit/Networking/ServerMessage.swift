import Foundation

/// Deciding whether the server's own words are fit to show a person.
///
/// A 4xx is the caller's fault and the server usually names it — often down to the exact field.
/// Both apps used to throw that away and substitute "Something went wrong on our end", which told
/// the user the server was broken when their input was the problem. That single sentence hid a
/// workout builder rejecting unnamed sections, a feed post dying in a stack overflow, and a
/// profile update failing on a misplaced annotation — for weeks, because nothing on screen could
/// distinguish a broken server from a rejected input.
///
/// The instinct behind hiding it was still right: a 4xx body can carry an exception class or a
/// stack frame, and none of that belongs in front of a user. So the rule is neither "always show"
/// nor "never show" — it is *show what reads like a sentence, hide what reads like a diagnostic*.
///
/// Lives here rather than in either app because both need exactly this judgement, and a copy that
/// drifts is a copy that starts leaking.
public enum ServerMessage {

    /// Markers that betray a diagnostic rather than copy written for a person.
    private static let leakMarkers = [
        "exception", "nullpointer", "stacktrace", "at com.", "at org.", "at java.",
        "sqlstate", "jdbc", "mongo", "hibernate", "java.lang", "servlet", "\n\tat "
    ]

    /// The server's message if it is safe and useful to display, otherwise nil.
    ///
    /// Nil means "fall back to the generic line" — the caller decides what that is, since the two
    /// apps word it slightly differently.
    public static func presentable(_ serverMessage: String?) -> String? {
        guard let raw = serverMessage?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else { return nil }

        // Too short to be a sentence (a bare code like "E42"), or long enough to be a dump.
        guard raw.count > 3, raw.count <= 200 else { return nil }

        let lowered = raw.lowercased()
        guard !leakMarkers.contains(where: { lowered.contains($0) }) else { return nil }

        return raw
    }

    /// The minimum shape of an error body that is *not* our own `ApiResponse` envelope.
    ///
    /// `APIResponse.success` is a non-optional `Bool`, so decoding a 4xx through the envelope
    /// fails outright on anything else — Spring's default error page
    /// (`{"timestamp","status","error","message","path"}`), a bare string, an empty body — and
    /// takes the server's explanation with it. This is the fallback read.
    public struct BareErrorBody: Decodable {
        public let message: String?
        public let error: String?
    }

    /// Pull a displayable message out of a raw error body, whatever shape it arrived in.
    ///
    /// - Parameters:
    ///   - data: the raw response body
    ///   - envelopeMessage: the message already decoded from the app's own `APIResponse`, if any.
    ///     Passed in because each app declares its own generic envelope type, which this package
    ///     cannot name.
    public static func presentable(data: Data, envelopeMessage: String?) -> String? {
        if let shown = presentable(envelopeMessage) { return shown }
        let bare = try? JSONDecoder().decode(BareErrorBody.self, from: data)
        return presentable(bare?.message) ?? presentable(bare?.error)
    }
}
