//
//  DSTabBarAppearance.swift
//  WarmupUIKit
//
//  The tab bar both apps use: surface fill with a hairline on top, 11pt labels (the one
//  place type goes below 13), secondary grey when idle, coral-as-text when selected.
//  Call once from the root tab view's init, and tint the TabView with DS.Color.primaryText.
//  On iOS 26 the system draws the floating Liquid Glass bar and keeps these colours.
//

import SwiftUI
import UIKit

public enum DSTabBarAppearance {
    @MainActor
    public static func apply() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(DS.Color.surface)
        appearance.shadowColor = UIColor(DS.Color.hairline)

        let item = UITabBarItemAppearance()
        item.normal.iconColor = UIColor(DS.Color.textSec)
        item.normal.titleTextAttributes = [
            .foregroundColor: UIColor(DS.Color.textSec),
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        item.selected.iconColor = UIColor(DS.Color.primaryText)
        item.selected.titleTextAttributes = [
            .foregroundColor: UIColor(DS.Color.primaryText),
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        appearance.stackedLayoutAppearance = item
        appearance.inlineLayoutAppearance = item
        appearance.compactInlineLayoutAppearance = item

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
