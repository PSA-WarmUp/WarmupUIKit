//
//  AuthRequests.swift
//  WarmupCore
//
//  Authentication request models
//

import Foundation

// MARK: - Login Request

public struct LoginRequest: Codable {
    public let email: String
    public let password: String

    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }

    public var isValid: Bool {
        return !email.isEmpty &&
               email.contains("@") &&
               password.count >= 6
    }
}

// MARK: - Trainer Registration Request

public struct TrainerRegistrationRequest: Codable {
    public let email: String
    public let password: String
    public let firstName: String
    public let lastName: String
    public let phoneNumber: String?

    public init(email: String, password: String, firstName: String, lastName: String, phoneNumber: String?) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
    }

    public var isValid: Bool {
        return !email.isEmpty &&
               email.contains("@") &&
               password.count >= 8 &&
               !firstName.isEmpty &&
               !lastName.isEmpty
    }
}

// MARK: - Update Profile Request

public struct UpdateProfileRequest: Codable {
    public let firstName: String?
    public let lastName: String?
    public let phoneNumber: String?
    public let bio: String?
    public let zipCode: String?
    public let city: String?
    public let state: String?

    public init(firstName: String? = nil, lastName: String? = nil, phoneNumber: String? = nil, bio: String? = nil, zipCode: String? = nil, city: String? = nil, state: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.bio = bio
        self.zipCode = zipCode
        self.city = city
        self.state = state
    }
}

// MARK: - Change Password Request

public struct ChangePasswordRequest: Codable {
    public let currentPassword: String
    public let newPassword: String
    public let confirmPassword: String
    public let logoutAllDevices: Bool

    public init(currentPassword: String, newPassword: String, confirmPassword: String, logoutAllDevices: Bool) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
        self.confirmPassword = confirmPassword
        self.logoutAllDevices = logoutAllDevices
    }

    public var isValid: Bool {
        return !currentPassword.isEmpty &&
               newPassword.count >= 8 &&
               newPassword == confirmPassword
    }
}

// MARK: - Timezone Request

public struct TimezoneRequest: Codable {
    public let timezone: String

    public init(timezone: String) {
        self.timezone = timezone
    }
}
