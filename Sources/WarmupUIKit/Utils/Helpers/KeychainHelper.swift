//
//  KeychainHelper.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 12/17/25.
//

import Foundation
import Security

public class KeychainHelper {

    // MARK: - Singleton
    public static let shared = KeychainHelper()

    // MARK: - Service Identifiers
    private let service = "com.warmup.trainer.auth"
    private let accessGroup: String? = nil // Set to your app group if needed

    // MARK: - Account Keys
    private enum AccountKeys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
        static let userInfo = "user_info"
        static let tokenExpiration = "token_expiration"
    }

    // MARK: - Error Types
    public enum KeychainError: Error, LocalizedError {
        case itemNotFound
        case invalidData
        case operationFailed(OSStatus)
        case serializationFailed

        public var errorDescription: String? {
            switch self {
            case .itemNotFound:
                return "Item not found in keychain"
            case .invalidData:
                return "Invalid data format"
            case .operationFailed(let status):
                return "Keychain operation failed with status: \(status)"
            case .serializationFailed:
                return "Failed to serialize/deserialize data"
            }
        }
    }

    // MARK: - Initializer
    public init() {}

    // MARK: - Public Methods

    // MARK: - Token Methods
    public func saveAccessToken(_ token: String) -> Bool {
        return save(token.data(using: .utf8), for: AccountKeys.accessToken)
    }

    public func getAccessToken() -> String? {
        guard let data = load(key: AccountKeys.accessToken),
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        return token
    }

    public func saveRefreshToken(_ token: String) -> Bool {
        return save(token.data(using: .utf8), for: AccountKeys.refreshToken)
    }

    public func getRefreshToken() -> String? {
        guard let data = load(key: AccountKeys.refreshToken),
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }
        return token
    }

    // MARK: - Token Response Methods
    public func saveTokenResponse(_ tokenResponse: TokenResponse) -> Bool {
        var success = true

        // Save access token
        success = success && saveAccessToken(tokenResponse.accessToken)

        // Save refresh token
        success = success && saveRefreshToken(tokenResponse.refreshToken)

        // Save expiration date
        success = success && saveTokenExpiration(tokenResponse.expirationDate)

        // Save user info if available
        if let user = tokenResponse.user {
            success = success && saveUser(user)
        }

        #if DEBUG
        if success {
            print("🔐 TokenResponse saved to keychain successfully")
        } else {
            print("❌ Failed to save TokenResponse to keychain")
        }
        #endif

        return success
    }

    public func getStoredTokenResponse() -> TokenResponse? {
        guard let accessToken = getAccessToken(),
              let refreshToken = getRefreshToken(),
              let expiration = getTokenExpiration() else {
            return nil
        }

        let expiresIn = max(0, Int(expiration.timeIntervalSinceNow))
        let user = getUser()

        return TokenResponse(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: "Bearer",
            expiresIn: expiresIn,
            user: user
        )
    }

    // MARK: - User Info Methods
    public func saveUser(_ user: User) -> Bool {
        do {
            let data = try JSONEncoder().encode(user)
            return save(data, for: AccountKeys.userInfo)
        } catch {
            #if DEBUG
            print("❌ Failed to encode user: \(error)")
            #endif
            return false
        }
    }

    public func getUser() -> User? {
        guard let data = load(key: AccountKeys.userInfo) else {
            return nil
        }

        do {
            return try JSONDecoder().decode(User.self, from: data)
        } catch {
            #if DEBUG
            print("❌ Failed to decode user: \(error)")
            #endif
            return nil
        }
    }

    // MARK: - Token Expiration Methods
    public func saveTokenExpiration(_ date: Date) -> Bool {
        let timestamp = date.timeIntervalSince1970
        let data = withUnsafeBytes(of: timestamp) { Data($0) }
        return save(data, for: AccountKeys.tokenExpiration)
    }

    public func getTokenExpiration() -> Date? {
        guard let data = load(key: AccountKeys.tokenExpiration),
              data.count == MemoryLayout<TimeInterval>.size else {
            return nil
        }

        let timestamp = data.withUnsafeBytes { $0.load(as: TimeInterval.self) }
        return Date(timeIntervalSince1970: timestamp)
    }

    // MARK: - Legacy Methods (for backward compatibility)
    public func save(token: String) {
        _ = saveAccessToken(token)
    }

    public func getToken() -> String? {
        return getAccessToken()
    }

    public func deleteToken() {
        clearAllTokens()
    }

    // MARK: - Clear Methods
    public func clearAllTokens() {
        _ = delete(key: AccountKeys.accessToken)
        _ = delete(key: AccountKeys.refreshToken)
        _ = delete(key: AccountKeys.userInfo)
        _ = delete(key: AccountKeys.tokenExpiration)

        #if DEBUG
        print("🔐 All tokens cleared from keychain")
        #endif
    }

    // MARK: - Clear Everything
    public func clearAll() {
        _ = delete(key: AccountKeys.accessToken)
        _ = delete(key: AccountKeys.refreshToken)
        _ = delete(key: AccountKeys.userInfo)
        _ = delete(key: AccountKeys.tokenExpiration)
        // Add any other keys you're storing
    }

    public func clearAccessToken() {
        _ = delete(key: AccountKeys.accessToken)
    }

    public func clearRefreshToken() {
        _ = delete(key: AccountKeys.refreshToken)
    }

    public func clearUserInfo() {
        _ = delete(key: AccountKeys.userInfo)
    }

    // MARK: - Validation Methods
    public func hasValidTokens() -> Bool {
        guard let accessToken = getAccessToken(),
              let refreshToken = getRefreshToken(),
              !accessToken.isEmpty,
              !refreshToken.isEmpty else {
            return false
        }

        // Check if tokens are expired
        if let expiration = getTokenExpiration() {
            return expiration > Date()
        }

        return true
    }

    public func hasRefreshToken() -> Bool {
        guard let refreshToken = getRefreshToken(),
              !refreshToken.isEmpty else {
            return false
        }
        return true
    }

    // MARK: - Core Keychain Operations

    // Generic save method
    public func save(_ data: Data?, for key: String) -> Bool {
        guard let data = data else { return false }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    // Generic load method
    public func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return data
        }
        return nil
    }

    // Generic delete method
    public func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: - Debug Methods
    public func printStoredItems() {
        #if DEBUG
        print("🔐 Keychain Status:")
        print("   • Access Token: \(getAccessToken() != nil ? "✅ Present" : "❌ Missing")")
        print("   • Refresh Token: \(getRefreshToken() != nil ? "✅ Present" : "❌ Missing")")
        print("   • User Info: \(getUser() != nil ? "✅ Present" : "❌ Missing")")

        if let expiration = getTokenExpiration() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            print("   • Token Expires: \(formatter.string(from: expiration))")
            print("   • Is Expired: \(expiration < Date() ? "❌ Yes" : "✅ No")")
        } else {
            print("   • Token Expiration: ❌ Missing")
        }
        #endif
    }
}
