//
//  User.swift
//  WarmupCore
//
//  Shared user model for WarmUp iOS apps
//

import Foundation

public struct User: Codable, Identifiable, Equatable, Hashable, Sendable {
    public let id: String
    public let email: String?  // Optional for phone-only users
    public let role: UserRole
    public let firstName: String?
    public let lastName: String?
    public let fullName: String?
    public let phoneNumber: String?
    public let profileImageUrl: String?
    public let isActive: Bool?
    public let emailVerified: Bool?
    public let trainerId: String?
    public let timezone: String?
    public let createdAt: String?
    public let lastLoginAt: String?
    public let updatedAt: String?

    // Location fields for trainer discovery
    public let zipCode: String?
    public let city: String?
    public let state: String?

    // Computed property for display name
    public var name: String {
        if let fullName = fullName, !fullName.contains("null") {
            return fullName
        } else if let firstName = firstName {
            if let lastName = lastName {
                return "\(firstName) \(lastName)"
            }
            return firstName
        } else if let email = email {
            return email.components(separatedBy: "@").first ?? "User"
        } else if let phone = phoneNumber {
            return phone.formatPhoneForDisplay()
        }
        return "User"
    }

    // Computed property for display
    public var displayName: String {
        return name
    }

    public enum UserRole: String, Codable, CaseIterable, Sendable {
        case trainer = "TRAINER"
        case client = "CLIENT"
    }

    enum CodingKeys: String, CodingKey {
        case id, email, role, firstName, lastName, fullName
        case phoneNumber, profileImageUrl, isActive, emailVerified
        case trainerId, timezone, createdAt, lastLoginAt, updatedAt
        case zipCode, city, state
    }

    // Computed property for formatted location
    public var formattedLocation: String? {
        var parts: [String] = []
        if let city = city, !city.isEmpty {
            parts.append(city)
        }
        if let state = state, !state.isEmpty {
            parts.append(state)
        }
        if let zipCode = zipCode, !zipCode.isEmpty {
            if parts.isEmpty {
                return zipCode
            }
            parts.append(zipCode)
        }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    // MARK: - Public Initializer

    public init(
        id: String,
        email: String?,
        role: UserRole,
        firstName: String?,
        lastName: String?,
        fullName: String?,
        phoneNumber: String?,
        profileImageUrl: String?,
        isActive: Bool?,
        emailVerified: Bool?,
        trainerId: String?,
        timezone: String?,
        createdAt: String?,
        lastLoginAt: String?,
        updatedAt: String?,
        zipCode: String?,
        city: String?,
        state: String?
    ) {
        self.id = id
        self.email = email
        self.role = role
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.profileImageUrl = profileImageUrl
        self.isActive = isActive
        self.emailVerified = emailVerified
        self.trainerId = trainerId
        self.timezone = timezone
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.updatedAt = updatedAt
        self.zipCode = zipCode
        self.city = city
        self.state = state
    }
}

// MARK: - Convenience Initializers

extension User {
    /// Simple initializer for test data
    public init(id: String, email: String, role: UserRole, name: String) {
        self.id = id
        self.email = email
        self.role = role
        self.firstName = name
        self.lastName = nil
        self.fullName = nil
        self.phoneNumber = nil
        self.profileImageUrl = nil
        self.isActive = true
        self.emailVerified = true
        self.trainerId = nil
        self.timezone = nil
        self.createdAt = ISO8601DateFormatter().string(from: Date())
        self.lastLoginAt = nil
        self.updatedAt = nil
        self.zipCode = nil
        self.city = nil
        self.state = nil
    }

    /// Factory method for test trainer
    public static func testTrainer(name: String = "Test Trainer", email: String? = nil) -> User {
        User(
            id: UUID().uuidString,
            email: email ?? "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@test.com",
            role: .trainer,
            name: name
        )
    }

    /// Factory method for test client
    public static func testClient(name: String = "Test Client", email: String? = nil) -> User {
        User(
            id: UUID().uuidString,
            email: email ?? "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@test.com",
            role: .client,
            name: name
        )
    }

    // Preview data
    public static var previewTrainer: User {
        User(id: "trainer-1", email: "trainer@example.com", role: .trainer, name: "John Trainer")
    }

    public static var previewClient: User {
        User(id: "client-1", email: "client@example.com", role: .client, name: "Jane Client")
    }

    public static var previewClients: [User] {
        [
            User(id: "1", email: "john@example.com", role: .client, name: "John Smith"),
            User(id: "2", email: "jane@example.com", role: .client, name: "Jane Doe"),
            User(id: "3", email: "sarah@example.com", role: .client, name: "Sarah Johnson"),
            User(id: "4", email: "mike@example.com", role: .client, name: "Mike Wilson")
        ]
    }
}

// MARK: - Auth Request Types
// Note: LoginRequest and TrainerRegistrationRequest are defined in AuthRequests.swift
