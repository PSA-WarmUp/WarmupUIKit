//
//  HealthPalette.swift
//  WarmupUIKit
//
//  Two colour families, and they carry provenance.
//
//  Coral is WarmUp — volume, sets, RPE, adherence, the prescription. Everything that exists
//  because a coach wrote it and a client did it.
//
//  Blue is connected health — HRV, resting heart rate, sleep, SpO₂. Everything measured by a
//  sensor we don't own.
//
//  Because the rule never varies, a chart with both colours in it is visibly a joined chart, and
//  no tile needs a logo explaining itself. Deliberately unbranded on the health side: it is Apple
//  Health today and may be a Garmin or a Whoop tomorrow.
//

import SwiftUI

public enum HealthPalette {
    /// WarmUp's own data.
    public static let load = DynamicTheme.Colors.primary
    /// Connected health data, whoever the provider is.
    public static let body = Color(red: 0.357, green: 0.553, blue: 0.851)   // #5b8dd9

    public static let bandTrack = DynamicTheme.Colors.divider
    public static let bandFill = Color(red: 0.169, green: 0.247, blue: 0.369).opacity(0.85) // #2b3f5e
    public static let neutralInk = DynamicTheme.Colors.textSecondary
}
