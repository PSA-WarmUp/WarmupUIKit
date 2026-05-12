//
//  DSTextField.swift
//  WarmupUIKit
//
//  Single source of truth for text inputs.
//

import SwiftUI

public enum DSTextFieldVariant {
    case filled
    case outlined
}

public struct DSTextField: View {
    public enum FieldKind {
        case text
        case secure
        case email
        case multiline(minHeight: CGFloat = 80)
    }

    let label: String?
    let placeholder: String
    @Binding var text: String
    let kind: FieldKind
    let variant: DSTextFieldVariant
    let hint: String?
    let error: String?
    let leadingIcon: String?
    let trailingIcon: String?
    let trailingAction: (() -> Void)?
    let submitLabel: SubmitLabel
    let onSubmit: (() -> Void)?

    @FocusState private var isFocused: Bool

    public init(
        label: String? = nil,
        placeholder: String = "",
        text: Binding<String>,
        kind: FieldKind = .text,
        variant: DSTextFieldVariant = .filled,
        hint: String? = nil,
        error: String? = nil,
        leadingIcon: String? = nil,
        trailingIcon: String? = nil,
        trailingAction: (() -> Void)? = nil,
        submitLabel: SubmitLabel = .return,
        onSubmit: (() -> Void)? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.kind = kind
        self.variant = variant
        self.hint = hint
        self.error = error
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.trailingAction = trailingAction
        self.submitLabel = submitLabel
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label = label {
                Text(label)
                    .dsCaptionMedium()
                    .foregroundColor(DS.Color.textSec)
            }

            HStack(spacing: 10) {
                if let leadingIcon = leadingIcon {
                    Image(systemName: leadingIcon)
                        .dsIcon(DS.Icon.md, weight: .regular)
                        .foregroundColor(isFocused ? DS.Tone.accent : DS.Color.textTer)
                        .frame(width: 22)
                        .accessibilityHidden(true)
                }

                input
                    .focused($isFocused)
                    .submitLabel(submitLabel)
                    .onSubmit { onSubmit?() }

                if let trailingIcon = trailingIcon {
                    Button {
                        trailingAction?()
                    } label: {
                        Image(systemName: trailingIcon)
                            .dsIcon(DS.Icon.md, weight: .regular)
                            .foregroundColor(DS.Color.textSec)
                    }
                    .dsTapTarget(32)
                    .accessibilityLabel(trailingIcon)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(fieldBackground)
            .overlay(borderOverlay)
            .clipShape(RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous))
            .animation(DS.Motion.tap, value: isFocused)
            .animation(DS.Motion.tap, value: error)

            if let error = error {
                Text(error)
                    .dsCaption()
                    .foregroundColor(DS.Color.error)
                    .accessibilityLabel("Error: \(error)")
            } else if let hint = hint {
                Text(hint)
                    .dsCaption()
                    .foregroundColor(DS.Color.textTer)
            }
        }
    }

    @ViewBuilder
    private var input: some View {
        switch kind {
        case .text:
            TextField(placeholder, text: $text)
                .dsBody()
                .foregroundColor(DS.Color.text)
                .textInputAutocapitalization(.sentences)
        case .secure:
            SecureField(placeholder, text: $text)
                .dsBody()
                .foregroundColor(DS.Color.text)
                .textContentType(.password)
        case .email:
            TextField(placeholder, text: $text)
                .dsBody()
                .foregroundColor(DS.Color.text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
        case .multiline(let minHeight):
            TextField(placeholder, text: $text, axis: .vertical)
                .dsBody()
                .foregroundColor(DS.Color.text)
                .lineLimit(3...10)
                .frame(minHeight: minHeight, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private var fieldBackground: some View {
        switch variant {
        case .filled:
            RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous)
                .fill(DS.Color.card)
        case .outlined:
            RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous)
                .fill(DS.Color.surface)
        }
    }

    @ViewBuilder
    private var borderOverlay: some View {
        let color: Color = {
            if error != nil { return DS.Color.error }
            if isFocused { return DS.Tone.accent }
            return DS.Color.hairline
        }()
        let width: CGFloat = (isFocused || error != nil) ? 1.5 : DS.Space.hairlineWidth
        RoundedRectangle(cornerRadius: DS.Space.innerRadius, style: .continuous)
            .stroke(color, lineWidth: width)
    }
}
