//
//  DSSheetChrome.swift
//  WarmupUIKit
//
//  Standardized sheet header.
//
//  Convention:
//    .close  → modal is informational/no-save
//    .done   → modal has changes to commit
//    .cancel → user might lose data (paired with explicit destructive intent)
//

import SwiftUI

public enum DSSheetTrailing {
    case none
    case done(action: () -> Void, isDisabled: Bool = false)
    case custom(label: String, action: () -> Void, isDisabled: Bool = false)
}

public enum DSSheetLeading {
    case close(action: () -> Void)
    case cancel(action: () -> Void)
    case back(action: () -> Void)
    case none
}

public struct DSSheetHeader: View {
    let title: String?
    let leading: DSSheetLeading
    let trailing: DSSheetTrailing

    public init(
        title: String? = nil,
        leading: DSSheetLeading = .close(action: {}),
        trailing: DSSheetTrailing = .none
    ) {
        self.title = title
        self.leading = leading
        self.trailing = trailing
    }

    public var body: some View {
        ZStack {
            if let title = title {
                Text(title)
                    .dsHeadline()
                    .foregroundColor(DS.Color.text)
                    .lineLimit(1)
            }
            HStack {
                leadingButton
                Spacer()
                trailingButton
            }
        }
        .padding(.horizontal, DS.Space.gutter)
        .frame(height: DS.Space.sheetHeader)
        .background(DS.Color.surface.opacity(0.95))
        .overlay(alignment: .bottom) {
            DSHairline()
        }
    }

    @ViewBuilder
    private var leadingButton: some View {
        switch leading {
        case .none:
            Color.clear.frame(width: 32, height: 32)
        case .close(let action):
            Button(action: action) {
                Image(systemName: "xmark")
                    .dsIcon(DS.Icon.md, weight: .semibold)
                    .foregroundColor(DS.Color.text)
            }
            .dsTapTarget()
            .accessibilityLabel("Close")
        case .cancel(let action):
            Button("Cancel", action: action)
                .dsCallout()
                .foregroundColor(DS.Color.text)
                .dsTapTarget()
                .accessibilityLabel("Cancel")
        case .back(let action):
            Button(action: action) {
                Image(systemName: "chevron.left")
                    .dsIcon(DS.Icon.md, weight: .semibold)
                    .foregroundColor(DS.Color.text)
            }
            .dsTapTarget()
            .accessibilityLabel("Back")
        }
    }

    @ViewBuilder
    private var trailingButton: some View {
        switch trailing {
        case .none:
            Color.clear.frame(width: 32, height: 32)
        case .done(let action, let isDisabled):
            Button("Done") {
                DS.Haptic.light()
                action()
            }
            .dsCalloutMedium()
            .foregroundColor(isDisabled ? DS.Color.textTer : DS.Tone.accent)
            .disabled(isDisabled)
            .dsTapTarget()
            .accessibilityLabel("Done")
        case .custom(let label, let action, let isDisabled):
            Button(label) {
                DS.Haptic.light()
                action()
            }
            .dsCalloutMedium()
            .foregroundColor(isDisabled ? DS.Color.textTer : DS.Tone.accent)
            .disabled(isDisabled)
            .dsTapTarget()
            .accessibilityLabel(label)
        }
    }
}

/// Convenience wrapper that lays out header above content.
public struct DSSheet<Content: View>: View {
    let title: String?
    let leading: DSSheetLeading
    let trailing: DSSheetTrailing
    let content: () -> Content

    public init(
        title: String? = nil,
        leading: DSSheetLeading = .close(action: {}),
        trailing: DSSheetTrailing = .none,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.leading = leading
        self.trailing = trailing
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            DSSheetHeader(title: title, leading: leading, trailing: trailing)
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DS.Color.bg)
        }
        .background(DS.Color.bg)
    }
}
