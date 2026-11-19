//
//  DSSheetChrome.swift
//  WarmupUIKit
//
//  Standardized sheet header. Every sheet in both apps follows ONE dismiss rule:
//
//    • A sheet that COMMITS something (save, send, book, add, pick a row)
//        → "Cancel" top-left, plus its commit: top-right (`.commit`) or a bottom
//          primary button / row tap inside the content (`.commitBelow`).
//    • A sheet that only SHOWS things, or edits LIVE (every change already saved)
//        → "Done" top-right (`.view`).
//
//  Never an xmark, "Close", "Dismiss", "Not now", or a leading "Done". Swipe down
//  still closes every sheet. Build a header from a `DSSheetRole` so the rule can't
//  be broken by accident:
//
//      DSSheet(title: "Health notes", role: .commitBelow(onCancel: { dismiss() })) { … }
//      DSSheet(title: "Appearance", role: .view(onDone: { dismiss() })) { … }
//
//  Sheets built on a NavigationStack use the same role with `.dsSheetActions(_:)`,
//  which places Cancel in `.cancellationAction` and Done/commit in `.confirmationAction`.
//
//  The older `leading:`/`trailing:` initialisers are deprecated. They still build,
//  and a deprecated `.close` is mapped onto the rule (Cancel when the sheet has a
//  trailing commit, otherwise Done top-right) — it never draws an xmark.
//

import SwiftUI

// MARK: - Role (the rule)

/// What a sheet does, which decides its dismiss controls. See the file header for the rule.
public enum DSSheetRole {
    /// Shows things or edits live → "Done" top-right.
    case view(onDone: () -> Void)
    /// Commits from the header → "Cancel" top-left, `title` (e.g. "Save", "Send") top-right.
    case commit(_ title: String, isDisabled: Bool = false, onCancel: () -> Void, action: () -> Void)
    /// Commits from the content (a bottom primary button, or tapping a row) → "Cancel" top-left only.
    case commitBelow(onCancel: () -> Void)
}

// MARK: - Legacy slots (deprecated)

public enum DSSheetTrailing {
    case none
    case done(action: () -> Void, isDisabled: Bool = false)
    case custom(label: String, action: () -> Void, isDisabled: Bool = false)
}

public enum DSSheetLeading {
    /// Deprecated: there is no xmark. Mapped to "Cancel" when the header has a trailing commit,
    /// otherwise to "Done" top-right.
    @available(*, deprecated, message: "No xmark: use DSSheetRole — .view(onDone:), .commit or .commitBelow(onCancel:)")
    case close(action: () -> Void)
    case cancel(action: () -> Void)
    /// For a pushed step inside a multi-step flow, not for dismissing a sheet.
    case back(action: () -> Void)
    case none
}

// MARK: - Resolved controls

/// The controls a header actually draws. Internal so the rule mapping can be unit-tested.
struct DSSheetControls {
    enum Leading { case none, cancel(() -> Void), back(() -> Void) }
    struct Trailing {
        let label: String
        let isDisabled: Bool
        let action: () -> Void
    }
    let leading: Leading
    let trailing: Trailing?

    init(role: DSSheetRole) {
        switch role {
        case .view(let onDone):
            leading = .none
            trailing = Trailing(label: "Done", isDisabled: false, action: onDone)
        case .commit(let title, let isDisabled, let onCancel, let action):
            leading = .cancel(onCancel)
            trailing = Trailing(label: title, isDisabled: isDisabled, action: action)
        case .commitBelow(let onCancel):
            leading = .cancel(onCancel)
            trailing = nil
        }
    }

    @available(*, deprecated)
    init(leading legacyLeading: DSSheetLeading, trailing legacyTrailing: DSSheetTrailing) {
        let mappedTrailing: Trailing?
        switch legacyTrailing {
        case .none: mappedTrailing = nil
        case .done(let action, let isDisabled):
            mappedTrailing = Trailing(label: "Done", isDisabled: isDisabled, action: action)
        case .custom(let label, let action, let isDisabled):
            mappedTrailing = Trailing(label: label, isDisabled: isDisabled, action: action)
        }
        switch legacyLeading {
        case .none:
            leading = .none
            trailing = mappedTrailing
        case .cancel(let action):
            leading = .cancel(action)
            trailing = mappedTrailing
        case .back(let action):
            leading = .back(action)
            trailing = mappedTrailing
        case .close(let action):
            if let mappedTrailing {
                leading = .cancel(action)
                trailing = mappedTrailing
            } else {
                leading = .none
                trailing = Trailing(label: "Done", isDisabled: false, action: action)
            }
        }
    }

    var leadingLabel: String? {
        switch leading {
        case .none: return nil
        case .cancel: return "Cancel"
        case .back: return "Back"
        }
    }
}

// MARK: - Header

public struct DSSheetHeader: View {
    let title: String?
    let controls: DSSheetControls

    /// The header for a sheet with the given role. Prefer this.
    public init(title: String? = nil, role: DSSheetRole) {
        self.title = title
        self.controls = DSSheetControls(role: role)
    }

    /// Deprecated. The default is no longer an xmark; `.close` maps onto the rule.
    @available(*, deprecated, message: "Use init(title:role:) so the sheet follows the Cancel/Done rule")
    public init(
        title: String? = nil,
        leading: DSSheetLeading = .none,
        trailing: DSSheetTrailing = .none
    ) {
        self.title = title
        self.controls = DSSheetControls(leading: leading, trailing: trailing)
    }

    public var body: some View {
        ZStack {
            if let title = title {
                Text(title)
                    .dsHeadline()
                    .foregroundColor(DS.Color.text)
                    .lineLimit(1)
                    .padding(.horizontal, 72)
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
        switch controls.leading {
        case .none:
            SwiftUI.Color.clear.frame(width: 32, height: 32)
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
        if let trailing = controls.trailing {
            Button(trailing.label) {
                DS.Haptic.light()
                trailing.action()
            }
            .dsCalloutMedium()
            .foregroundColor(trailing.isDisabled ? DS.Color.textTer : DS.Color.primaryText)
            .disabled(trailing.isDisabled)
            .dsTapTarget()
            .accessibilityLabel(trailing.label)
        } else {
            SwiftUI.Color.clear.frame(width: 32, height: 32)
        }
    }
}

// MARK: - Sheet

/// Convenience wrapper that lays out header above content.
public struct DSSheet<Content: View>: View {
    let header: DSSheetHeader
    let content: () -> Content

    public init(
        title: String? = nil,
        role: DSSheetRole,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = DSSheetHeader(title: title, role: role)
        self.content = content
    }

    @available(*, deprecated, message: "Use init(title:role:content:) so the sheet follows the Cancel/Done rule")
    public init(
        title: String? = nil,
        leading: DSSheetLeading = .none,
        trailing: DSSheetTrailing = .none,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = DSSheetHeader(title: title, leading: leading, trailing: trailing)
        self.content = content
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DS.Color.bg)
        }
        .background(DS.Color.bg)
    }
}

// MARK: - NavigationStack sheets

private struct DSSheetActionsModifier: ViewModifier {
    let controls: DSSheetControls

    func body(content: Content) -> some View {
        content.toolbar {
            if case .cancel(let action) = controls.leading {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: action)
                }
            }
            if let trailing = controls.trailing {
                ToolbarItem(placement: .confirmationAction) {
                    Button(trailing.label) {
                        DS.Haptic.light()
                        trailing.action()
                    }
                    .fontWeight(.semibold)
                    .disabled(trailing.isDisabled)
                }
            }
        }
    }
}

public extension View {
    /// The sheet's dismiss controls as standard toolbar items, for sheets built on a
    /// NavigationStack: Cancel → `.cancellationAction`, Done/commit → `.confirmationAction`.
    /// Same rule as `DSSheetHeader(role:)`.
    func dsSheetActions(_ role: DSSheetRole) -> some View {
        modifier(DSSheetActionsModifier(controls: DSSheetControls(role: role)))
    }
}
