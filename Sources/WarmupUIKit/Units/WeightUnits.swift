//
//  WeightUnits.swift
//  WarmupUIKit
//
//  Pounds and kilograms, decided once for both apps.
//
//  Nothing is converted on the way in. Every weight is stored in the unit it was entered in and
//  travels with that unit — a client who logged 225 lb has 225 stored, forever, and a coach
//  reading in kilos sees 102. Normalising on write would push every entry through a float and
//  hand people back a 224.9 they never lifted, and a later preference change would then convert
//  the converted value. The unit a number was recorded in is a fact about that number; it does
//  not get rewritten because someone flipped a switch in settings.
//
//  Displayed weights land on the increment plates come in — 2.5 lb or 1 kg. A gym has no
//  102.058 kg, and three decimals of false precision is how a converted number announces that
//  it was converted.
//

import Foundation

public enum WeightUnit: String, CaseIterable, Codable, Sendable {
    case imperial = "IMPERIAL"
    case metric = "METRIC"

    /// What the number is labelled with.
    public var suffix: String { self == .metric ? "kg" : "lbs" }

    public var title: String { self == .metric ? "Kilograms" : "Pounds" }
    public var subtitle: String { self == .metric ? "kg" : "lb" }

    /// The device's own answer, for a client who has never chosen.
    ///
    /// Guessing from the phone is right far more often than defaulting everyone to pounds, and
    /// it is only ever a default — the moment someone picks, their choice wins.
    public static var deviceDefault: WeightUnit {
        if #available(iOS 16.0, *) {
            return Locale.current.measurementSystem == .metric ? .metric : .imperial
        }
        return Locale.current.usesMetricSystem ? .metric : .imperial
    }
}

public enum Weights {
    private static let lbPerKg = 2.20462262

    /// True when a stored unit string means kilograms. Tolerant: "kg", "KG", "kgs", nil.
    public static func isMetric(_ unit: String?) -> Bool {
        guard let unit else { return false }
        return unit.trimmingCharacters(in: .whitespaces).lowercased().hasPrefix("kg")
    }

    /// Convert a stored weight for display. `preference` nil leaves the stored number alone.
    public static func convert(_ value: Double?, storedUnit: String?, to preference: WeightUnit?) -> Double? {
        guard let value, let preference else { return value }
        let stored = isMetric(storedUnit)
        switch preference {
        case .metric:   return round(stored ? value : value / lbPerKg, .metric)
        case .imperial: return round(stored ? value * lbPerKg : value, .imperial)
        }
    }

    /// Round to the increment plates come in.
    public static func round(_ value: Double, _ unit: WeightUnit) -> Double {
        unit == .metric ? value.rounded() : ((value / 2.5).rounded() * 2.5)
    }

    /// Bodyweight is measured, not loaded — whole units both ways. Nobody weighs themselves to
    /// the nearest 2.5 lb.
    public static func convertBodyweight(_ value: Double?, storedUnit: String?, to preference: WeightUnit?) -> Double? {
        guard let value, let preference else { return value }
        let stored = isMetric(storedUnit)
        switch preference {
        case .metric:   return (stored ? value : value / lbPerKg).rounded()
        case .imperial: return (stored ? value * lbPerKg : value).rounded()
        }
    }

    /// A display string, already converted and labelled: "225 lbs", "102 kg".
    public static func display(_ value: Double?, storedUnit: String?, to preference: WeightUnit?) -> String? {
        guard let value, value > 0 else { return nil }
        let converted = convert(value, storedUnit: storedUnit, to: preference) ?? value
        let unit = preference?.suffix ?? storedUnit ?? "lbs"
        let whole = converted.truncatingRemainder(dividingBy: 1) == 0
        return whole ? "\(Int(converted)) \(unit)" : String(format: "%.1f %@", converted, unit)
    }
}

// MARK: - The stored choice

/// Where the app remembers the reader's unit.
///
/// Local so every screen can read it synchronously while rendering, and pushed to the server so
/// it survives a reinstall and follows the person to a new device.
@MainActor
public final class UnitPreferenceStore: ObservableObject {
    public static let shared = UnitPreferenceStore()

    private static let key = "warmup.unitPreference"

    /// Nil until the client chooses; readers fall back to `WeightUnit.deviceDefault`.
    @Published public private(set) var stored: WeightUnit?

    /// What to actually display in — never nil, so call sites don't each invent a fallback.
    public var effective: WeightUnit { stored ?? .deviceDefault }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.key) {
            stored = WeightUnit(rawValue: raw)
        }
    }

    public func set(_ unit: WeightUnit) {
        stored = unit
        UserDefaults.standard.set(unit.rawValue, forKey: Self.key)
    }

    /// Adopt the server's value on login, without clobbering a local choice made offline.
    public func adoptFromServer(_ raw: String?) {
        guard stored == nil, let raw, let unit = WeightUnit(rawValue: raw) else { return }
        set(unit)
    }
}
