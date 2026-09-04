//
//  DSToolCall.swift
//  WarmupUIKit
//
//  What the agent read before it answered.
//
//  The co-pilot pulls a client's journal, their PRs, their readiness and their recent sessions,
//  then speaks in confident prose. Without this row, that is indistinguishable from an agent
//  that made it up — and a coach who can't tell the difference is right not to trust either.
//
//  So: one line per step, in the order they happened, before the answer. It says what was read
//  and for whom, never what came back — the prose already carries the findings, and a detail
//  line quoting someone's journal would put their words somewhere they never chose to share.
//
//  The 1.5pt left rule is the only coloured left border in the system, and it carries state:
//  accent while running, muted when done, red when the lookup failed. A failed step still
//  shows, because hiding it makes "I couldn't find that client" read as a refusal rather than
//  a lookup that came back empty.
//

import SwiftUI

public struct DSToolCall: View {

    public enum State {
        case running, done, failed
    }

    private let label: String
    private let detail: String?
    private let state: State

    public init(label: String, detail: String? = nil, state: State = .done) {
        self.label = label
        self.detail = detail
        self.state = state
    }

    private var tone: Color {
        switch state {
        case .running: return DS.Color.primary
        case .failed:  return DS.Color.error
        case .done:    return DS.Color.textSec
        }
    }

    public var body: some View {
        HStack(spacing: DS.Space.v8) {
            Text(label)
                .font(DS.Typo.eyebrow)
                .tracking(DS.Track.eyebrow)
                .textCase(.uppercase)
                .foregroundStyle(tone)
                .lineLimit(1)

            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(DS.Typo.numericCaption)
                    .foregroundStyle(DS.Color.textTer)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: 0)

            if state == .running {
                Circle()
                    .fill(tone)
                    .frame(width: 5, height: 5)
                    .opacity(pulse ? 0.3 : 1)
                    .animation(
                        DS.Motion.curve.repeatForever(autoreverses: true),
                        value: pulse
                    )
                    .onAppear { pulse = true }
            }
        }
        .padding(.horizontal, DS.Space.v12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous)
                .fill(DS.Color.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous)
                .stroke(DS.Color.hairline, lineWidth: DS.Space.hairlineWidth)
        )
        .overlay(alignment: .leading) {
            // The state, carried by the rule rather than by a word.
            UnevenRoundedRectangle(
                topLeadingRadius: DS.Space.innerRadius,
                bottomLeadingRadius: DS.Space.innerRadius,
                style: .continuous
            )
            .fill(tone)
            .frame(width: 1.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    @SwiftUI.State private var pulse = false

    /// VoiceOver gets the sentence, not the row: "Read their journal, Shiv, failed."
    private var accessibilityText: String {
        var text = label
        if let detail, !detail.isEmpty { text += ", " + detail }
        switch state {
        case .running: text += ", in progress"
        case .failed:  text += ", failed"
        case .done:    break
        }
        return text
    }
}

// MARK: - A run of steps

/// The full receipt for one answer. Renders nothing when the agent needed no data, so a plain
/// chat turn doesn't grow an empty container.
public struct DSToolCallList: View {
    private let steps: [Step]

    public struct Step: Identifiable, Equatable {
        public let id: String
        public let label: String
        public let detail: String?
        public let ok: Bool

        public init(id: String = UUID().uuidString, label: String, detail: String?, ok: Bool) {
            self.id = id
            self.label = label
            self.detail = detail
            self.ok = ok
        }
    }

    public init(steps: [Step]) {
        self.steps = steps
    }

    public var body: some View {
        if !steps.isEmpty {
            VStack(alignment: .leading, spacing: DS.Space.v4) {
                ForEach(steps) { step in
                    DSToolCall(label: step.label,
                               detail: step.detail,
                               state: step.ok ? .done : .failed)
                }
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: DS.Space.v8) {
        DSToolCall(label: "Checked where they're at", detail: "Shiv", state: .running)
        DSToolCall(label: "Read their journal", detail: "Shiv")
        DSToolCall(label: "Looked up their PRs", detail: "Shiv · squat", state: .failed)
    }
    .padding()
    .background(DS.Color.bg)
}
