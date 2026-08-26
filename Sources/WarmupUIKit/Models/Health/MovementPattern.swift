//
//  MovementPattern.swift
//  WarmupUIKit
//
//  Sorting exercises into the regions a coach actually programmes in.
//
//  We store muscles, not movement patterns, so push/pull is a rule rather than a fact: chest and
//  delts push, back and biceps pull. It is a reasonable rule and a trainer should be able to
//  disagree with it — which is why anything unrecognised lands in `.unknown` and is shown as
//  unclassified rather than quietly folded into whichever bucket is nearest.
//

import Foundation

public enum MovementPattern: String, CaseIterable, Identifiable {
    case push, pull, legs, core, cardio, unknown

    public var id: String { rawValue }

    public var label: String {
        switch self {
        case .push:    return "Push"
        case .pull:    return "Pull"
        case .legs:    return "Legs"
        case .core:    return "Core"
        case .cardio:  return "Cardio"
        case .unknown: return "Unclassified"
        }
    }

    /// Best guess from whatever the exercise carries — muscle groups first, then the name.
    ///
    /// The name fallback matters: the catalogue's muscle data is incomplete, and "Bench Press"
    /// is recognisable even when nothing was tagged.
    public static func classify(muscleGroups: [String]?, category: String?, name: String) -> MovementPattern {
        if let category, isCardio(category) { return .cardio }

        if let muscleGroups {
            for group in muscleGroups {
                if let pattern = fromKeyword(group), pattern != .unknown { return pattern }
            }
        }
        if let pattern = fromKeyword(name), pattern != .unknown { return pattern }
        if let category, let pattern = fromKeyword(category), pattern != .unknown { return pattern }
        return .unknown
    }

    private static func isCardio(_ raw: String) -> Bool {
        let value = raw.lowercased()
        return value.contains("cardio") || value.contains("conditioning") || value.contains("endurance")
    }

    private static func fromKeyword(_ raw: String) -> MovementPattern? {
        let v = raw.lowercased()
        if v.contains("chest") || v.contains("pec") || v.contains("bench")
            || v.contains("push") || v.contains("dip") || v.contains("tricep")
            || v.contains("shoulder") || v.contains("delt") || v.contains("overhead") { return .push }
        if v.contains("back") || v.contains("lat") || v.contains("row")
            || v.contains("pull") || v.contains("chin") || v.contains("bicep")
            || v.contains("curl") || v.contains("deadlift") { return .pull }
        if v.contains("leg") || v.contains("quad") || v.contains("hamstring")
            || v.contains("glute") || v.contains("squat") || v.contains("lunge")
            || v.contains("calf") || v.contains("hip") { return .legs }
        if v.contains("core") || v.contains("ab") || v.contains("plank")
            || v.contains("oblique") || v.contains("carry") { return .core }
        if isCardio(v) || v.contains("run") || v.contains("row machine")
            || v.contains("bike") || v.contains("cycle") { return .cardio }
        return nil
    }
}
