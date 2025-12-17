//
//  String+Extensions.swift
//  WarmupCore
//
//  String utilities and extensions
//

import Foundation

public extension String {
    /// Format phone number for display
    func formatPhoneForDisplay() -> String {
        let digits = self.filter { $0.isNumber }
        if digits.count == 10 {
            let areaCode = String(digits.prefix(3))
            let prefix = String(digits.dropFirst(3).prefix(3))
            let suffix = String(digits.suffix(4))
            return "(\(areaCode)) \(prefix)-\(suffix)"
        } else if digits.count == 11 && digits.hasPrefix("1") {
            let withoutCountry = String(digits.dropFirst())
            let areaCode = String(withoutCountry.prefix(3))
            let prefix = String(withoutCountry.dropFirst(3).prefix(3))
            let suffix = String(withoutCountry.suffix(4))
            return "+1 (\(areaCode)) \(prefix)-\(suffix)"
        }
        return self
    }

    /// Check if string is valid email
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }

    /// Check if string is valid password (min 8 chars)
    var isValidPassword: Bool {
        return self.count >= 8
    }

    /// Trim whitespace and newlines
    var trimmed: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Convert to simple date format (yyyy-MM-dd)
    func toSimpleDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: self)
    }

    /// Convert ISO8601 string to Date
    func toISO8601Date() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: self) {
            return date
        }
        // Try without fractional seconds
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self)
    }
}
