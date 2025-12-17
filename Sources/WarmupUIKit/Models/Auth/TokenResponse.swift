//
//  TokenResponse.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 9/1/25.
//
// In TokenResponse.swift
import Foundation

public struct TokenResponse: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let user: User?  // Now backend sends this!

    public init(accessToken: String, refreshToken: String, tokenType: String, expiresIn: Int, user: User?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.user = user
    }

    // Map snake_case from backend
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case user = "user"  // Backend now includes this
    }

    public var expirationDate: Date {
        return Date().addingTimeInterval(TimeInterval(expiresIn))
    }

    public var isExpired: Bool {
        return Date() >= expirationDate
    }

    public var willExpireSoon: Bool {
            let threshold: TimeInterval = 300 // 5 minutes
            return Date().addingTimeInterval(threshold) >= expirationDate
        }
}

// MARK: - Refresh Token Request (ADD THIS!)
public struct RefreshTokenRequest: Codable {
    public let refreshToken: String

    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

// MARK: - Legacy Login/Signup Response (for backward compatibility)
public struct AuthResponse: Codable {
    public let success: Bool
    public let message: String?
    public let token: String? // Legacy - will be replaced by TokenResponse
    public let user: User?

    public init(success: Bool, message: String?, token: String?, user: User?) {
        self.success = success
        self.message = message
        self.token = token
        self.user = user
    }

    // Convert to new TokenResponse format
    public func toTokenResponse() -> TokenResponse? {
        guard let token = token, let user = user else { return nil }
        return TokenResponse(
            accessToken: token,
            refreshToken: "", // Will need to handle this separately
            tokenType: "Bearer",
            expiresIn: 3600, // Default 1 hour
            user: user
        )
    }
}
