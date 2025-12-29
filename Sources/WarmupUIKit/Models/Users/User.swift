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

    // Subscription tiers (separate from role)
    public let trainerTier: TrainerTier?        // For trainers: STARTER, GROWTH, SCALE, PRO
    public let subscriptionTier: SubscriptionTier?  // For clients: FREE, PAID, PREMIUM

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

    // MARK: - Role (what type of user)
    public enum UserRole: String, Codable, CaseIterable, Sendable {
        case trainer = "TRAINER"
        case client = "CLIENT"
        case admin = "ADMIN"
        case facilityOwner = "FACILITY_OWNER"
        case moderator = "MODERATOR"
        case postOwner = "POST_OWNER"

        public var isClient: Bool { self == .client }
        public var isTrainer: Bool { self == .trainer }
        public var canAccessTrainerApp: Bool { self == .trainer }

        public var displayName: String {
            switch self {
            case .trainer: return "Trainer"
            case .client: return "Client"
            case .admin: return "Admin"
            case .facilityOwner: return "Facility Owner"
            case .moderator: return "Moderator"
            case .postOwner: return "Post Owner"
            }
        }
    }

    // MARK: - Trainer Tier (pricing/limits for trainers)
    public enum TrainerTier: String, Codable, CaseIterable, Sendable {
        case starter = "STARTER"   // 1-5 clients @ $10/client
        case growth = "GROWTH"     // 6-15 clients @ $7.50/client
        case scale = "SCALE"       // 16-25 clients @ $5/client
        case pro = "PRO"           // Unlimited @ $0/client

        public var displayName: String {
            switch self {
            case .starter: return "Starter"
            case .growth: return "Growth"
            case .scale: return "Scale"
            case .pro: return "Pro"
            }
        }

        public var maxClients: Int {
            switch self {
            case .starter: return 5
            case .growth: return 15
            case .scale: return 25
            case .pro: return Int.max
            }
        }

        public var pricePerClient: Double {
            switch self {
            case .starter: return 10.00
            case .growth: return 7.50
            case .scale: return 5.00
            case .pro: return 0.00
            }
        }

        /// Calculate monthly billing based on client count (progressive pricing)
        public static func calculateMonthlyBilling(clientCount: Int) -> Double {
            var total: Double = 0
            // First 5 at $10
            total += Double(min(clientCount, 5)) * 10.0
            // 6-15 at $7.50
            if clientCount > 5 {
                total += Double(min(clientCount - 5, 10)) * 7.5
            }
            // 16+ at $5
            if clientCount > 15 {
                total += Double(clientCount - 15) * 5.0
            }
            return total
        }
    }

    // MARK: - Subscription Tier (for clients)
    public enum SubscriptionTier: String, Codable, CaseIterable, Sendable {
        case free = "FREE"
        case paid = "PAID"
        case premium = "PREMIUM"

        public var displayName: String {
            switch self {
            case .free: return "Free"
            case .paid: return "Paid"
            case .premium: return "Premium"
            }
        }

        public var isPaid: Bool {
            self == .paid || self == .premium
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, email, role, firstName, lastName, fullName
        case phoneNumber, profileImageUrl, isActive, emailVerified
        case trainerId, timezone, createdAt, lastLoginAt, updatedAt
        case zipCode, city, state
        case trainerTier, subscriptionTier
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

    // MARK: - Helper Methods

    /// Whether this user is a trainer
    public var isTrainer: Bool { role.isTrainer }

    /// Whether this user is a client
    public var isClient: Bool { role.isClient }

    /// Whether this trainer is on Pro tier (unlimited clients)
    public var isProTrainer: Bool {
        role.isTrainer && trainerTier == .pro
    }

    /// Whether this client has a paid subscription
    public var isPaidClient: Bool {
        role.isClient && (subscriptionTier?.isPaid ?? false)
    }

    /// Check if trainer can add more clients based on their tier
    public func canAddMoreClients(currentCount: Int) -> Bool {
        guard role.isTrainer else { return false }
        let tier = trainerTier ?? .starter
        return currentCount < tier.maxClients
    }

    /// Get the trainer's current tier display name
    public var trainerTierDisplayName: String {
        (trainerTier ?? .starter).displayName
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
        state: String?,
        trainerTier: TrainerTier? = nil,
        subscriptionTier: SubscriptionTier? = nil
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
        self.trainerTier = trainerTier
        self.subscriptionTier = subscriptionTier
    }
}

// MARK: - Convenience Initializers

extension User {
    /// Simple initializer for test data
    public init(id: String, email: String, role: UserRole, name: String, trainerTier: TrainerTier? = nil, subscriptionTier: SubscriptionTier? = nil) {
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
        self.trainerTier = trainerTier
        self.subscriptionTier = subscriptionTier
    }

    /// Factory method for test trainer
    public static func testTrainer(name: String = "Test Trainer", email: String? = nil, tier: TrainerTier = .starter) -> User {
        User(
            id: UUID().uuidString,
            email: email ?? "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@test.com",
            role: .trainer,
            name: name,
            trainerTier: tier
        )
    }

    /// Factory method for test client
    public static func testClient(name: String = "Test Client", email: String? = nil, tier: SubscriptionTier = .premium) -> User {
        User(
            id: UUID().uuidString,
            email: email ?? "\(name.lowercased().replacingOccurrences(of: " ", with: "."))@test.com",
            role: .client,
            name: name,
            subscriptionTier: tier
        )
    }

    // Preview data
    public static var previewTrainer: User {
        User(id: "trainer-1", email: "trainer@example.com", role: .trainer, name: "John Trainer", trainerTier: .starter)
    }

    public static var previewProTrainer: User {
        User(id: "trainer-2", email: "pro@example.com", role: .trainer, name: "Pro Trainer", trainerTier: .pro)
    }

    public static var previewClient: User {
        User(id: "client-1", email: "client@example.com", role: .client, name: "Jane Client", subscriptionTier: .premium)
    }

    public static var previewClients: [User] {
        [
            User(id: "1", email: "john@example.com", role: .client, name: "John Smith", subscriptionTier: .premium),
            User(id: "2", email: "jane@example.com", role: .client, name: "Jane Doe", subscriptionTier: .premium),
            User(id: "3", email: "sarah@example.com", role: .client, name: "Sarah Johnson", subscriptionTier: .premium),
            User(id: "4", email: "mike@example.com", role: .client, name: "Mike Wilson", subscriptionTier: .premium)
        ]
    }
}
