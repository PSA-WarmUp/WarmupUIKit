//
//  DSChat.swift
//  WarmupUIKit
//
//  The pieces of a chat thread both apps draw the same way:
//  - `dsChatBubble(isOwn:)`: the 18pt bubble — coral fill for what you sent, card for what you got.
//  - `DSChatTextBubble`: a text message inside that bubble (16pt; near-black on coral).
//  - `DSChatMeta`: the "9:41 · Read" line under a run of messages (13pt, time in mono).
//  - `DSChatComposer`: "+" (optional), the growing field and the round send button.
//

import SwiftUI

public extension View {
    /// The chat bubble behind a message: coral for your own, card for the other person's.
    func dsChatBubble(isOwn: Bool) -> some View {
        background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(isOwn ? DS.Color.primary : DS.Color.card)
        )
    }
}

/// A plain text message in its bubble.
public struct DSChatTextBubble: View {
    let text: String
    let isOwn: Bool

    public init(_ text: String, isOwn: Bool) {
        self.text = text
        self.isOwn = isOwn
    }

    public var body: some View {
        Text(text)
            .font(.system(size: 16))
            .foregroundStyle(isOwn ? DS.Color.onPrimary : DS.Color.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .textSelection(.enabled)
            .dsChatBubble(isOwn: isOwn)
    }
}

/// "9:41 · Read" under the last message of a run. `status` is nil on received messages.
public struct DSChatMeta: View {
    let time: String
    let status: String?

    public init(time: String, status: String? = nil) {
        self.time = time
        self.status = status
    }

    public var body: some View {
        HStack(spacing: 4) {
            Text(time)
                .font(.system(size: 13, design: .monospaced))
            if let status {
                Text("· \(status)")
                    .font(.system(size: 13))
            }
        }
        .foregroundStyle(DS.Color.textSec)
    }
}

/// The message composer: an optional "+" for attachments, the field (grows to 5 lines) and a
/// round send button that is coral only when there is something to send.
public struct DSChatComposer: View {
    @Binding var text: String
    let isSending: Bool
    let placeholder: String
    let attachmentLabel: String
    let onAttachment: (() -> Void)?
    let onSend: () -> Void

    @FocusState private var focused: Bool

    public init(
        text: Binding<String>,
        isSending: Bool = false,
        placeholder: String = "Message",
        attachmentLabel: String = "Attach",
        onAttachment: (() -> Void)? = nil,
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.isSending = isSending
        self.placeholder = placeholder
        self.attachmentLabel = attachmentLabel
        self.onAttachment = onAttachment
        self.onSend = onSend
    }

    private var isEmpty: Bool { text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    public var body: some View {
        VStack(spacing: 0) {
            DS.Color.hairline.frame(height: DS.Space.hairlineWidth)

            HStack(alignment: .bottom, spacing: 8) {
                if let onAttachment {
                    Button(action: onAttachment) {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(DS.Color.text)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(DS.Color.cardHi))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(attachmentLabel)
                }

                TextField(placeholder, text: $text, axis: .vertical)
                    .font(.system(size: 16))
                    .foregroundStyle(DS.Color.text)
                    .focused($focused)
                    .lineLimit(1...5)
                    .onSubmit { if !isEmpty { onSend() } }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(DS.Color.card))

                Button(action: onSend) {
                    ZStack {
                        if isSending {
                            ProgressView().tint(DS.Color.textSec)
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(isEmpty ? DS.Color.textTer : DS.Color.onPrimary)
                        }
                    }
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(isEmpty ? DS.Color.cardHi : DS.Color.primary))
                }
                .buttonStyle(.plain)
                .disabled(isEmpty || isSending)
                .accessibilityLabel("Send")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(DS.Color.bg)
        }
    }
}
