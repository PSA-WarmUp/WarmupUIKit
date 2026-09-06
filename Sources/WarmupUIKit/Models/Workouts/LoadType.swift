import Foundation

/// How a set is loaded — the client half of the backend's `LoadTypes` contract.
///
/// The plan sheet rendered *"15 reps · bodyweight lbs"* and the logging screen offered a numeric
/// weight field placeheld with the truncated word `"bo…"`, because the literal token "bodyweight"
/// was living inside a field that is otherwise a number, and a unit was being appended to it
/// unconditionally. A marker, rather than a magic string, is what lets a screen know it should
/// stop asking for a number the user cannot supply.
///
/// Values match the server exactly. The server also sends a pre-built `displaySummary` on every
/// set; prefer that when it is present — it is the one place the wording is decided, so both apps
/// and the share card cannot disagree.
public enum LoadType: String, Codable, Sendable, CaseIterable {

    /// Load comes off a rack: barbell, dumbbell, machine, cable.
    case external = "EXTERNAL"

    /// The body is the load. No numeric weight field belongs on screen.
    case bodyweight = "BODYWEIGHT"

    /// The body plus added load — a weighted pull-up, a dip with a belt. `weight` is the
    /// *added* load only.
    case bodyweightPlus = "BODYWEIGHT_PLUS"

    /// Neither loaded nor bodyweight-bearing: a stretch, a mobility drill.
    case unloaded = "UNLOADED"

    /// Resolve from whatever the payload actually carries.
    ///
    /// Older rows have no marker and instead spell "bodyweight" into the free-text weight, so
    /// that is read as a fallback. Nothing is migrated server-side, which means this fallback is
    /// load-bearing rather than transitional.
    public static func resolve(marker: String?, prescribedWeight: String?) -> LoadType {
        if let marker, let known = LoadType(rawValue: marker.trimmingCharacters(in: .whitespaces).uppercased()) {
            return known
        }
        if let weight = prescribedWeight?.lowercased() {
            let saysBodyweight = weight.contains("bodyweight") || weight.trimmingCharacters(in: .whitespaces) == "bw"
            if saysBodyweight {
                // "bodyweight + 25" is the added-load case, written by hand.
                return weight.rangeOfCharacter(from: .decimalDigits) != nil ? .bodyweightPlus : .bodyweight
            }
        }
        return .external
    }

    /// True when no numeric weight input should be offered.
    ///
    /// `bodyweightPlus` is deliberately false: the added plate is the client's own number and
    /// they still need somewhere to put it.
    public var hidesWeightInput: Bool {
        self == .bodyweight || self == .unloaded
    }

    /// The load half of a set summary — "bodyweight", "100 lbs", "bodyweight + 25 lbs".
    ///
    /// Nil when there is nothing to say, so a caller can omit the separator rather than print
    /// an empty segment. Never appends a unit to the word "bodyweight".
    public func describeLoad(weight: Double?, unit: String?) -> String? {
        let resolvedUnit = (unit?.isEmpty == false) ? unit! : "lbs"

        switch self {
        case .bodyweight:
            return "bodyweight"
        case .unloaded:
            return nil
        case .bodyweightPlus:
            guard let weight, weight > 0 else { return "bodyweight" }
            return "bodyweight + \(Self.trim(weight)) \(resolvedUnit)"
        case .external:
            guard let weight else { return nil }
            return "\(Self.trim(weight)) \(resolvedUnit)"
        }
    }

    /// "12 reps · 100 lbs". `reps` is passed as text so a range ("8-12") reads naturally.
    public func describeSet(reps: String?, weight: Double?, unit: String?) -> String {
        var parts: [String] = []
        if let reps, !reps.isEmpty { parts.append("\(reps) reps") }
        if let load = describeLoad(weight: weight, unit: unit) { parts.append(load) }
        return parts.joined(separator: " · ")
    }

    /// 100.0 prints as "100"; 102.5 keeps its half.
    private static func trim(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }
}

public extension String {
    /// The number out of a free-text prescription, when there is one.
    ///
    /// The field legitimately holds "75% of max" and "moderate" as well as "135", so anything
    /// that is not a plain quantity contributes no load — better to render "12 reps" than to
    /// invent a weight out of a percentage.
    var prescribedWeightValue: Double? {
        let text = trimmingCharacters(in: .whitespaces).lowercased()
        if let plain = Double(text.replacingOccurrences(of: "lbs", with: "")
                                  .replacingOccurrences(of: "lb", with: "")
                                  .replacingOccurrences(of: "kg", with: "")
                                  .trimmingCharacters(in: .whitespaces)) {
            return plain
        }
        // "bodyweight + 25" — the added half is the number.
        guard let plus = text.range(of: "+") else { return nil }
        return Double(text[plus.upperBound...].trimmingCharacters(in: .whitespaces))
    }
}

/// Reading a number a person typed.
///
/// `Double("7,5")` is nil — the initializer only understands a period, while a `.decimalPad` in a
/// French or German locale offers a comma. Every RPE and weight field in both apps parsed with the
/// bare initializer, so those users' entries silently vanished: the field looked accepted, the
/// value arrived nil, and the set logged without it.
public enum NumericInput {

    /// Parse a user-typed decimal, honouring their locale's separator and tolerating the other.
    public static func double(_ text: String?) -> Double? {
        guard let raw = text?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        if let n = formatter.number(from: raw) { return n.doubleValue }

        // Someone pasting "7.5" into a comma locale, or the reverse.
        return Double(raw.replacingOccurrences(of: ",", with: "."))
    }

    /// RPE is prescribed and logged on a 1–10 scale in half steps. Returns nil for anything else,
    /// so an off-grid value is refused at the field rather than persisted and puzzled over later.
    public static func rpe(_ text: String?) -> Double? {
        guard let value = double(text), value >= 1, value <= 10 else { return nil }
        return (value * 2).rounded() == value * 2 ? value : nil
    }

    /// "7.5" keeps its half; "8.0" prints as "8". The scale is read by people, not machines.
    public static func formatRpe(_ value: Double) -> String {
        value == value.rounded() ? String(Int(value)) : String(value)
    }

    /// True when the text is present but not a usable RPE — the state a field should mark.
    public static func isInvalidRpe(_ text: String?) -> Bool {
        guard let raw = text?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else { return false }
        return rpe(raw) == nil
    }
}
