//
//  AuthError.swift
//  WarmupCore
//
//  Authentication error types
//

import Foundation

public enum AuthError: Error, LocalizedError, Equatable {
    case unknownError
    case loginFailed
    case invalidCredentials(String)
    case userNotFound
    case emailAlreadyExists
    case weakPassword
    case tokenExpired
    case refreshTokenExpired
    case networkError(String)
    case validationError(String)
    case unauthorizedRole(String)
    case registrationFailed(String)
    case notATrainer(String)
    case profileFetchFailed
    case updateFailed
    case notAuthenticated

    // OTP/Phone Auth Errors
    case otpSendFailed(String)
    case otpVerificationFailed(String)
    case invalidPhoneNumber
    case phoneAlreadyLinked
    case otpRateLimited(secondsRemaining: Int)
    case otpLockout(message: String)

    public var errorDescription: String? {
        switch self {
        case .unknownError:
            return "Unknown Error"
        case .loginFailed:
            return "Failed to log into the application"
        case .invalidCredentials(let message):
            return message
        case .userNotFound:
            return "User not found"
        case .emailAlreadyExists:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password must be at least 8 characters long"
        case .tokenExpired:
            return "Your session has expired. Please log in again."
        case .refreshTokenExpired:
            return "Your session has expired. Please log in again."
        case .networkError(let message):
            return "Network error: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .unauthorizedRole(let message):
            return message
        case .registrationFailed(let message):
            return message
        case .notATrainer(let message):
            return message
        case .profileFetchFailed:
            return "Failed to fetch profile"
        case .updateFailed:
            return "Profile update failed"
        case .notAuthenticated:
            return "Not authenticated"
        case .otpSendFailed(let message):
            return message
        case .otpVerificationFailed(let message):
            return message
        case .invalidPhoneNumber:
            return "Please enter a valid phone number"
        case .phoneAlreadyLinked:
            return "This phone number is already linked to another account"
        case .otpRateLimited(let seconds):
            return "Please wait \(seconds) seconds before requesting a new code"
        case .otpLockout(let message):
            return message
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidCredentials:
            return "Please check your email and password and try again."
        case .userNotFound:
            return "Please check your email or create a new account."
        case .emailAlreadyExists:
            return "Try logging in with this email or use a different email address."
        case .weakPassword:
            return "Use a stronger password with at least 8 characters."
        case .tokenExpired, .refreshTokenExpired:
            return "Please log in again to continue."
        case .networkError:
            return "Please check your internet connection and try again."
        case .otpSendFailed:
            return "Please check your phone number and try again."
        case .otpVerificationFailed:
            return "Please check the code and try again, or request a new code."
        case .invalidPhoneNumber:
            return "Enter your phone number with country code (e.g., +1 for US)."
        case .phoneAlreadyLinked:
            return "Try logging in with this phone number instead."
        case .otpRateLimited:
            return "You'll be able to request a new code when the timer expires."
        case .otpLockout:
            return "Too many failed attempts. Please wait and try again later."
        default:
            return "Please try again or contact support if the problem persists."
        }
    }
}
