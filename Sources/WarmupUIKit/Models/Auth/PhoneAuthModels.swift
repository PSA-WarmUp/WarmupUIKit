//
//  PhoneAuthModels.swift
//  WarmupCore
//
//  Phone/OTP authentication request and response models
//

import Foundation

// MARK: - OTP Request Models

/// Request to send OTP code to a phone number
public struct SendOtpRequest: Codable {
    public let phone: String

    public init(phone: String) {
        self.phone = phone
    }

    /// Validates E.164 phone format (e.g., +14155551234)
    public var isValid: Bool {
        let pattern = "^\\+[1-9]\\d{7,14}$"
        return phone.range(of: pattern, options: .regularExpression) != nil
    }
}

/// Request to verify OTP code and authenticate
public struct VerifyOtpRequest: Codable {
    public let phone: String
    public let code: String

    public init(phone: String, code: String) {
        self.phone = phone
        self.code = code
    }

    /// Validates phone format and OTP code (4-8 digits)
    public var isValid: Bool {
        let phonePattern = "^\\+[1-9]\\d{7,14}$"
        let codePattern = "^\\d{4,8}$"
        return phone.range(of: phonePattern, options: .regularExpression) != nil &&
               code.range(of: codePattern, options: .regularExpression) != nil
    }
}

/// Request to link phone number to existing account
public struct LinkPhoneRequest: Codable {
    public let phone: String
    public let code: String

    public init(phone: String, code: String) {
        self.phone = phone
        self.code = code
    }

    public var isValid: Bool {
        let phonePattern = "^\\+[1-9]\\d{7,14}$"
        let codePattern = "^\\d{4,8}$"
        return phone.range(of: phonePattern, options: .regularExpression) != nil &&
               code.range(of: codePattern, options: .regularExpression) != nil
    }
}

// MARK: - OTP Response Models

/// Response from OTP verification containing auth tokens and user status
public struct PhoneAuthResponse: Codable {
    public let token: String?
    public let refreshToken: String?
    public let isNewUser: Bool?
    public let profileCompleted: Bool?
    public let role: String?
    public let userId: String?

    public init(token: String?, refreshToken: String?, isNewUser: Bool?, profileCompleted: Bool?, role: String?, userId: String?) {
        self.token = token
        self.refreshToken = refreshToken
        self.isNewUser = isNewUser
        self.profileCompleted = profileCompleted
        self.role = role
        self.userId = userId
    }

    /// Convenience accessor for access token (matches existing TokenResponse pattern)
    public var accessToken: String? { token }

    /// Check if user needs to complete onboarding
    public var needsOnboarding: Bool {
        isNewUser == true || profileCompleted == false
    }

    /// Parsed user role
    public var userRole: User.UserRole? {
        guard let role = role else { return nil }
        return User.UserRole(rawValue: role)
    }
}

// MARK: - OTP Error Responses

/// Rate limit error when requesting OTP too frequently (429)
public struct OtpRateLimitError: Codable {
    public let success: Bool?
    public let message: String?
    public let errorCode: String?
    public let details: RateLimitDetails?

    public init(success: Bool?, message: String?, errorCode: String?, details: RateLimitDetails?) {
        self.success = success
        self.message = message
        self.errorCode = errorCode
        self.details = details
    }

    public struct RateLimitDetails: Codable {
        public let secondsRemaining: Int?

        public init(secondsRemaining: Int?) {
            self.secondsRemaining = secondsRemaining
        }
    }

    /// Seconds until next OTP can be requested
    public var secondsRemaining: Int {
        details?.secondsRemaining ?? 60
    }
}

/// Lockout error after too many failed verification attempts (429)
public struct OtpLockoutError: Codable {
    public let success: Bool?
    public let message: String?
    public let errorCode: String?

    public init(success: Bool?, message: String?, errorCode: String?) {
        self.success = success
        self.message = message
        self.errorCode = errorCode
    }

    /// Check if this is a lockout vs rate limit
    public var isLockout: Bool {
        errorCode == "OTP_LOCKOUT"
    }
}

/// Generic OTP error response that can be either rate limit or lockout
public struct OtpErrorResponse: Codable {
    public let success: Bool?
    public let message: String?
    public let errorCode: String?
    public let details: OtpErrorDetails?

    public init(success: Bool?, message: String?, errorCode: String?, details: OtpErrorDetails?) {
        self.success = success
        self.message = message
        self.errorCode = errorCode
        self.details = details
    }

    public struct OtpErrorDetails: Codable {
        public let secondsRemaining: Int?

        public init(secondsRemaining: Int?) {
            self.secondsRemaining = secondsRemaining
        }
    }

    public var isRateLimited: Bool {
        errorCode == "OTP_RATE_LIMITED"
    }

    public var isLockout: Bool {
        errorCode == "OTP_LOCKOUT"
    }

    public var secondsRemaining: Int {
        details?.secondsRemaining ?? 60
    }
}

// MARK: - Auth State

/// Authentication state for routing
public enum AuthState: Equatable {
    case loggedOut
    case loggedIn
    case onboarding(userId: String, existingRole: User.UserRole?)

    public var isAuthenticated: Bool {
        switch self {
        case .loggedOut:
            return false
        case .loggedIn, .onboarding:
            return true
        }
    }
}

// MARK: - Profile Setup Request

/// Request to complete profile setup during onboarding
public struct ProfileSetupRequest: Codable {
    public let firstName: String
    public let lastName: String
    public let role: String?  // "TRAINER" or "CLIENT" - optional for existing users
    public let profileImageUrl: String?

    public init(firstName: String, lastName: String, role: String?, profileImageUrl: String?) {
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
        self.profileImageUrl = profileImageUrl
    }

    public var isValid: Bool {
        !firstName.trimmed.isEmpty &&
        !lastName.trimmed.isEmpty
    }

    /// Creates a request for new users who need a role assigned
    public static func forNewUser(firstName: String, lastName: String, role: User.UserRole, profileImageUrl: String? = nil) -> ProfileSetupRequest {
        ProfileSetupRequest(
            firstName: firstName,
            lastName: lastName,
            role: role.rawValue,
            profileImageUrl: profileImageUrl
        )
    }

    /// Creates a request for existing users who already have a role (doesn't send role)
    public static func forExistingUser(firstName: String, lastName: String, profileImageUrl: String? = nil) -> ProfileSetupRequest {
        ProfileSetupRequest(
            firstName: firstName,
            lastName: lastName,
            role: nil,
            profileImageUrl: profileImageUrl
        )
    }
}

// MARK: - Phone Formatting Helpers
// Note: formatPhoneForDisplay() is defined in String+Extensions.swift
