//
//  AppConstants.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 12/17/25.
//

import Foundation

public struct AppConstants {
    public struct API {
        #if DEBUG
        public static let baseURL = "http://localhost:8080"
        #else
        public static let baseURL = "https://api.warmup.app" // Production URL
        #endif

        public static let timeout: TimeInterval = 30
        public static let maxRetries = 3
    }

    public struct Storage {
        public static let authTokenKey = "warmup_auth_token"
        public static let refreshTokenKey = "warmup_refresh_token"
        public static let userInfoKey = "warmup_user_info"
        public static let tokenExpirationKey = "warmup_token_expiration"
        public static let lastLoginKey = "warmup_last_login"
    }

    public struct Validation {
        public static let minPasswordLength = 8
        public static let maxPasswordLength = 128
        public static let maxNameLength = 50
        public static let maxBioLength = 500
        public static let maxWorkoutNotesLength = 5000
    }

    public struct UI {
        public static let animationDuration = 0.3
        public static let keyboardAnimationDuration = 0.25
        public static let toastDuration = 3.0
        public static let maxChatBubbleWidth: CGFloat = 280
    }

    public struct Features {
        public static let enableDMs = true
        public static let enableFeed = false // Coming soon
        public static let enableVoiceNotes = false
        public static let enableVideoUploads = false
    }

    public struct AppConfig {
        public static let appType = "TRAINER"  // This app is for trainers only
        public static let appName = "WarmUp Trainer"
        // Note: requiredRole references User.UserRole which should be defined in your Models

        // Feature flags
        public static let features: [String: Bool] = [
            "clientManagement": true,
            "programCreation": true,
            "workoutAssignment": true,
            "analytics": true,
            "invitations": true,
            "scheduling": true
        ]
    }
}
