//
//  DSSettingsRow.swift
//  WarmupUIKit
//
//  A settings row: 16pt regular title, optional trailing value, chevron. 48pt tall.
//  Lives in a DSRowGroup like any other row (Me, settings screens). Not a button itself —
//  wrap it in a NavigationLink or Button with `.buttonStyle(.plain)`.
//
//    DSRowGroup {
//        NavigationLink(value: Route.notifications) { DSSettingsRow("Notifications") }
//        Button { showTheme = true } label: { DSSettingsRow("Appearance", value: "Dark") }
//    }
//

import SwiftUI

public struct DSSettingsRow<Trailing: View>: View {
    let title: String
    let trailing: Trailing

    /// A row with a custom trailing view before the chevron (a badge, a count).
    public init(_ title: String, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(DS.Color.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
            trailing
            DSChevron()
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }
}

public extension DSSettingsRow where Trailing == EmptyView {
    init(_ title: String) {
        self.init(title, trailing: { EmptyView() })
    }
}

public extension DSSettingsRow where Trailing == Text {
    /// A row showing its current value ("Appearance … Dark").
    init(_ title: String, value: String) {
        self.init(title, trailing: {
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(DS.Color.textSec)
        })
    }
}
