//
//  HealthSubject.swift
//  WarmupUIKit
//
//  Who the cards are talking about.
//
//  These cards were written for a client reading their own data, so the copy is second
//  person: "What you trained". A coach opening the same cards on a client detail page needs
//  the same sentences about someone else, and "your body is keeping pace" is plainly wrong
//  when the body is Finley's.
//
//  Rather than fork the views or thread a pile of strings through them, each card that says
//  something about a person takes a subject and asks it for the right word.
//

import Foundation

public enum HealthSubject {
    /// The person reading the screen, looking at their own data.
    case you
    /// Someone else, by first name — a coach looking at a client.
    case person(String)

    /// "you" / "Finley" — the one doing the training.
    public var nominative: String {
        switch self {
        case .you: return "you"
        case .person(let name): return name
        }
    }

    /// "your" / "Finley's" — for the thing being described.
    public var possessive: String {
        switch self {
        case .you: return "your"
        case .person(let name): return name + "'s"
        }
    }

    /// True when the reader is the subject, for copy that only makes sense first-hand —
    /// a prompt to connect a health source belongs to the person who owns the phone.
    public var isSelf: Bool {
        if case .you = self { return true }
        return false
    }
}
