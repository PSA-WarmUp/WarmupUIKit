//
//  AuthService.swift
//  WarmupCore
//
//  Public authentication service for WarmUp apps
//

import Foundation
import Combine

@MainActor
open class AuthService: ObservableObject {
    public static let shared = AuthService()

    // MARK: - Published Properties
    @Published public var isAuthenticated = false
    @Published public var currentUser: User?
    @Published public var isLoading = false
    @Published public var authError: String?
    @Published public var accessToken: String?
    @Published public var refreshToken: String?
    @Published public var authState: AuthState = .loggedOut
    @Published public var isLinkingMode = false  // For phone linking flow

    // MARK: - Private Properties
    private let networkService = NetworkService.shared
    private let keychain = KeychainHelper()
    private var cancellables = Set<AnyCancellable>()

    // Track if session check has been performed
    private var hasCheckedStoredSession = false

    // MARK: - Initialization

    public init() {
        // Don't check stored session here - defer to after UI loads
        // Call initializeSessionIfNeeded() from app's ContentView.onAppear
    }

    // MARK: - Session Management

    /// Initialize session from stored tokens - call this AFTER UI is ready
    /// This defers Keychain reads to avoid blocking app startup
    open func initializeSessionIfNeeded() async {
        guard !hasCheckedStoredSession else { return }
        hasCheckedStoredSession = true
        await checkStoredSession()
    }

    // MARK: - Email/Password Authentication

    /// Login with email and password
    open func login(email: String, password: String) -> AnyPublisher<Bool, Error> {
        isLoading = true
        authError = nil

        let loginRequest = LoginRequest(email: email, password: password)

        return networkService.post(
            APIEndpoints.Auth.login,
            body: loginRequest,
            requiresAuth: false
        )
        .receive(on: DispatchQueue.main)
        .tryMap { [weak self] (response: APIResponse<TokenResponse>) -> Bool in
            guard let self = self else { throw AuthError.unknownError }

            guard response.success, let tokenResponse = response.data else {
                throw AuthError.loginFailed
            }

            // Store tokens (UI updates automatically on MainActor)
            self.accessToken = tokenResponse.accessToken
            self.refreshToken = tokenResponse.refreshToken

            // Store user if included (backend now sends this!)
            if let user = tokenResponse.user {
                self.currentUser = user
                self.isAuthenticated = true

                // Sync timezone after successful login
                self.syncTimezone()
            } else {
                // If no user in response, fetch profile (fallback)
                Task {
                    await self.fetchUserProfileAsync()
                    // Sync timezone after profile fetch
                    self.syncTimezone()
                }
            }

            // Save tokens in background
            Task.detached {
                _ = await self.keychain.saveTokenResponse(tokenResponse)
            }

            return true
        }
        .handleEvents(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.authError = error.localizedDescription
                }
            }
        )
        .eraseToAnyPublisher()
    }

    /// Login trainer with email and password (with role verification)
    open func loginTrainer(email: String, password: String) -> AnyPublisher<Bool, Error> {
        isLoading = true
        authError = nil

        let loginRequest = LoginRequest(email: email, password: password)

        return networkService.post(
            APIEndpoints.Auth.login,
            body: loginRequest,
            requiresAuth: false
        )
        .receive(on: DispatchQueue.main)
        .tryMap { [weak self] (response: APIResponse<TokenResponse>) -> Bool in
            guard let self = self else { throw AuthError.unknownError }

            guard response.success, let tokenResponse = response.data else {
                throw AuthError.invalidCredentials(response.message ?? "Login failed")
            }

            self.accessToken = tokenResponse.accessToken
            self.refreshToken = tokenResponse.refreshToken

            // CRITICAL: Verify user is a trainer
            if let user = tokenResponse.user {
                guard user.role == .trainer else {
                    throw AuthError.notATrainer("This app is for trainers only. Please use the client app.")
                }
                self.currentUser = user
                self.isAuthenticated = true
                self.authState = .loggedIn

                // Sync timezone after successful login
                self.syncTimezone()
            }

            // If user not included in response, fetch profile
            if tokenResponse.user == nil {
                Task { @MainActor [keychain = self.keychain] in
                    _ = keychain.saveTokenResponse(tokenResponse)

                    await self.fetchUserProfileAsync()
                    self.authState = .loggedIn
                    // Sync timezone after profile fetch
                    self.syncTimezone()
                }
            } else {
                // Save tokens in background
                Task.detached {
                    _ = self.keychain.saveTokenResponse(tokenResponse)
                }
            }

            return true
        }
        .handleEvents(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.authError = error.localizedDescription
                }
            }
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Registration

    /// Register a new trainer account
    open func registerTrainer(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        phoneNumber: String
    ) -> AnyPublisher<Bool, Error> {

        isLoading = true
        authError = nil
        print("📝 Starting trainer registration for: \(email)")

        let registrationRequest = TrainerRegistrationRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber
        )

        // NOW WE GET TOKENS DIRECTLY FROM REGISTRATION!
        return networkService.post(
            APIEndpoints.Auth.registerTrainer,
            body: registrationRequest,
            requiresAuth: false
        )
        .receive(on: DispatchQueue.main)
        .tryMap { [weak self] (response: APIResponse<TokenResponse>) -> Bool in
            guard let self = self else { throw AuthError.unknownError }

            guard response.success, let tokenResponse = response.data else {
                let message = response.message ?? "Registration failed"
                if message.contains("already exists") {
                    throw AuthError.emailAlreadyExists
                }
                throw AuthError.registrationFailed(message)
            }

            // Store tokens (UI updates automatically on MainActor)
            self.accessToken = tokenResponse.accessToken
            self.refreshToken = tokenResponse.refreshToken

            // Store user if included
            if let user = tokenResponse.user {
                // Verify it's a trainer
                guard user.role == .trainer else {
                    self.logout()
                    throw AuthError.notATrainer("This app is for trainers only")
                }
                self.currentUser = user
                self.isAuthenticated = true
            }

            // Save tokens to keychain in background
            Task.detached {
                _ = await self.keychain.saveTokenResponse(tokenResponse)
            }

            print("✅ Trainer registered and authenticated successfully")
            return true
        }
        .handleEvents(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.authError = error.localizedDescription
                }
            }
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Profile Management

    /// Fetch user profile (Publisher version)
    open func fetchUserProfile() -> AnyPublisher<Bool, Error> {
        return networkService.get(APIEndpoints.Auth.me)
            .receive(on: DispatchQueue.main)
            .tryMap { [weak self] (response: APIResponse<User>) -> Bool in
                guard let self = self else { throw AuthError.unknownError }

                guard response.success, let user = response.data else {
                    throw AuthError.profileFetchFailed
                }

                // Update user (UI updates automatically on MainActor)
                self.currentUser = user
                self.isAuthenticated = true

                // Save user to keychain in background
                Task.detached {
                    _ = await self.keychain.saveUser(user)
                }

                return true
            }
            .eraseToAnyPublisher()
    }

    /// Async version for internal use
    @MainActor
    private func fetchUserProfileAsync() async {
        do {
            let response: APIResponse<User> = try await withCheckedThrowingContinuation { continuation in
                networkService.get(APIEndpoints.Auth.me)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                continuation.resume(throwing: error)
                            }
                        },
                        receiveValue: { response in
                            continuation.resume(returning: response)
                        }
                    )
                    .store(in: &cancellables)
            }

            print("🔍 API Response - success: \(response.success), hasData: \(response.data != nil)")

            guard response.success, let user = response.data else {
                print("❌ Profile fetch failed - success: \(response.success), message: \(response.message ?? "none")")
                throw AuthError.profileFetchFailed
            }

            print("🔍 User from API - name: \(user.name), role: \(user.role.rawValue)")

            // Update user (already on MainActor)
            self.currentUser = user
            self.isAuthenticated = true

            print("✅ User profile fetched and set: \(user.name), currentUser is now: \(self.currentUser?.name ?? "nil")")

            // Save user to keychain in background
            Task.detached {
                _ = await self.keychain.saveUser(user)
            }
        } catch {
            print("❌ Failed to fetch user profile: \(error)")
            authError = error.localizedDescription
        }
    }

    /// Update user profile
    open func updateProfile(
        firstName: String? = nil,
        lastName: String? = nil,
        phoneNumber: String? = nil,
        bio: String? = nil,
        zipCode: String? = nil,
        city: String? = nil,
        state: String? = nil
    ) -> AnyPublisher<Bool, Error> {
        guard let userId = currentUser?.id else {
            return Fail(error: AuthError.notAuthenticated).eraseToAnyPublisher()
        }

        let updateRequest = UpdateProfileRequest(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            bio: bio,
            zipCode: zipCode,
            city: city,
            state: state
        )

        return networkService.put(
            APIEndpoints.Users.updateProfile(userId),
            body: updateRequest
        )
        .receive(on: DispatchQueue.main)
        .tryMap { [weak self] (response: APIResponse<User>) -> Bool in
            guard response.success, let updatedUser = response.data else {
                throw AuthError.updateFailed
            }

            // Update current user (UI updates automatically on MainActor)
            self?.currentUser = updatedUser

            // Save to keychain in background
            Task.detached {
                _ = await self?.keychain.saveUser(updatedUser)
            }

            return true
        }
        .eraseToAnyPublisher()
    }

    /// Change password
    open func changePassword(
        currentPassword: String,
        newPassword: String,
        logoutAllDevices: Bool = true
    ) -> AnyPublisher<Bool, Error> {
        let changePasswordRequest = ChangePasswordRequest(
            currentPassword: currentPassword,
            newPassword: newPassword,
            confirmPassword: newPassword,
            logoutAllDevices: logoutAllDevices
        )

        return networkService.post(
            APIEndpoints.Auth.changePassword,
            body: changePasswordRequest
        )
        .receive(on: DispatchQueue.main)
        .map { (response: APIResponse<EmptyResponse>) -> Bool in
            return response.success
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Phone/OTP Authentication

    /// Sends an OTP code to the specified phone number
    open func sendOtp(phone: String) -> AnyPublisher<Bool, Error> {
        isLoading = true
        authError = nil

        let request = SendOtpRequest(phone: phone)

        return networkService.post(
            APIEndpoints.Auth.sendOtp,
            body: request,
            requiresAuth: false
        )
        .receive(on: DispatchQueue.main)
        .tryMap { (response: APIResponse<EmptyResponse>) -> Bool in
            guard response.success else {
                throw AuthError.otpSendFailed(response.message ?? "Failed to send OTP")
            }
            return true
        }
        .handleEvents(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.authError = error.localizedDescription
                }
            }
        )
        .eraseToAnyPublisher()
    }

    /// Verifies OTP code and authenticates the user
    open func verifyOtp(phone: String, code: String) -> AnyPublisher<PhoneAuthResponse, Error> {
        isLoading = true
        authError = nil

        let request = VerifyOtpRequest(phone: phone, code: code)

        return networkService.post(
            APIEndpoints.Auth.verifyOtp,
            body: request,
            requiresAuth: false
        )
        .receive(on: DispatchQueue.main)
        .tryMap { [weak self] (response: APIResponse<PhoneAuthResponse>) -> PhoneAuthResponse in
            guard let self = self else { throw AuthError.unknownError }
            guard response.success, let authResponse = response.data else {
                throw AuthError.otpVerificationFailed(response.message ?? "Invalid OTP code")
            }

            // Store tokens
            self.accessToken = authResponse.token
            self.refreshToken = authResponse.refreshToken

            // Save tokens to keychain FIRST before any profile fetch
            if let token = authResponse.token, let refresh = authResponse.refreshToken {
                let tokenResponse = TokenResponse(
                    accessToken: token,
                    refreshToken: refresh,
                    tokenType: "Bearer",
                    expiresIn: 3600,
                    user: nil
                )
                // Save synchronously to ensure token is available for subsequent requests
                _ = self.keychain.saveTokenResponse(tokenResponse)
            }

            // Determine auth state based on response
            if authResponse.isNewUser == true || authResponse.profileCompleted == false {
                // New user or incomplete profile -> onboarding
                // Pass existing role so we don't try to change it for existing users
                self.authState = .onboarding(userId: authResponse.userId ?? "", existingRole: authResponse.userRole)
                self.isAuthenticated = true
            } else {
                // Existing user with complete profile
                self.authState = .loggedIn
                self.isAuthenticated = true
                Task {
                    await self.fetchUserProfileAsync()
                    self.syncTimezone()
                }
            }

            return authResponse
        }
        .handleEvents(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.authError = error.localizedDescription
                }
            }
        )
        .eraseToAnyPublisher()
    }

    /// Sends OTP to link phone to existing authenticated account
    open func sendLinkPhoneOtp(phone: String) -> AnyPublisher<Bool, Error> {
        isLoading = true
        authError = nil
        isLinkingMode = true

        let request = SendOtpRequest(phone: phone)

        return networkService.post(
            APIEndpoints.Auth.sendLinkPhoneOtp,
            body: request,
            requiresAuth: true
        )
        .receive(on: DispatchQueue.main)
        .tryMap { (response: APIResponse<EmptyResponse>) -> Bool in
            guard response.success else {
                if response.message?.contains("already linked") == true {
                    throw AuthError.phoneAlreadyLinked
                }
                throw AuthError.otpSendFailed(response.message ?? "Failed to send OTP")
            }
            return true
        }
        .handleEvents(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.authError = error.localizedDescription
                    self?.isLinkingMode = false
                }
            }
        )
        .eraseToAnyPublisher()
    }

    /// Verifies OTP and links phone to current account
    open func verifyAndLinkPhone(phone: String, code: String) -> AnyPublisher<Bool, Error> {
        isLoading = true
        authError = nil

        let request = LinkPhoneRequest(phone: phone, code: code)

        return networkService.post(
            APIEndpoints.Auth.verifyAndLinkPhone,
            body: request,
            requiresAuth: true
        )
        .receive(on: DispatchQueue.main)
        .tryMap { [weak self] (response: APIResponse<EmptyResponse>) -> Bool in
            guard response.success else {
                if response.message?.contains("already linked") == true {
                    throw AuthError.phoneAlreadyLinked
                }
                throw AuthError.otpVerificationFailed(response.message ?? "Failed to verify OTP")
            }

            // Refresh user profile to get updated phone number
            Task {
                await self?.fetchUserProfileAsync()
            }

            self?.isLinkingMode = false
            return true
        }
        .handleEvents(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.authError = error.localizedDescription
                }
                self?.isLinkingMode = false
            }
        )
        .eraseToAnyPublisher()
    }

    /// Completes profile setup during onboarding
    open func completeProfileSetup(firstName: String, lastName: String, role: User.UserRole, profileImageUrl: String? = nil) -> AnyPublisher<Bool, Error> {
        // Extract userId and existing role from auth state
        var userId: String?
        var existingRole: User.UserRole?

        if let currentId = currentUser?.id {
            userId = currentId
            existingRole = currentUser?.role
        } else if case .onboarding(let id, let role) = authState {
            userId = id
            existingRole = role
        }

        guard let userId = userId else {
            return Fail(error: AuthError.notAuthenticated).eraseToAnyPublisher()
        }

        isLoading = true
        authError = nil

        // Only send role if user doesn't already have one (backward compatibility)
        let request: ProfileSetupRequest
        if let existingRole = existingRole {
            // User already has a role - don't try to change it
            request = ProfileSetupRequest.forExistingUser(
                firstName: firstName,
                lastName: lastName,
                profileImageUrl: profileImageUrl
            )
        } else {
            // New user - set the role
            request = ProfileSetupRequest.forNewUser(
                firstName: firstName,
                lastName: lastName,
                role: role,
                profileImageUrl: profileImageUrl
            )
        }

        return networkService.put(
            APIEndpoints.Users.updateProfile(userId),
            body: request
        )
        .receive(on: DispatchQueue.main)
        .tryMap { [weak self] (response: APIResponse<User>) -> Bool in
            guard let self = self else { throw AuthError.unknownError }
            guard response.success, let user = response.data else {
                throw AuthError.updateFailed
            }

            self.currentUser = user
            self.authState = .loggedIn
            self.syncTimezone()

            // Save to keychain
            Task.detached {
                _ = await self.keychain.saveUser(user)
            }

            return true
        }
        .handleEvents(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.authError = error.localizedDescription
                }
            }
        )
        .eraseToAnyPublisher()
    }

    // MARK: - Logout

    /// Logout and clear all authentication data
    open func logout() {
        // Clear UI state IMMEDIATELY (don't wait for Keychain)
        accessToken = nil
        refreshToken = nil
        currentUser = nil
        isAuthenticated = false
        authError = nil
        authState = .loggedOut
        isLinkingMode = false

        // Clear Keychain in background (non-blocking)
        Task.detached(priority: .background) { [keychain] in
            _ = keychain.delete(key: AppConstants.Storage.authTokenKey)
            keychain.clearAllTokens()
        }

        print("👋 User logged out and tokens cleared")
    }

    // MARK: - Session Management

    /// Check stored session from keychain
    @MainActor
    private func checkStoredSession() async {
        guard let tokenResponse = keychain.getStoredTokenResponse() else {
            print("🔐 No stored session found")
            return
        }

        // Check if tokens are expired
        if tokenResponse.isExpired {
            print("🔐 Stored tokens expired, clearing...")
            logout()
            return
        }

        // Restore tokens to properties (already on MainActor)
        self.accessToken = tokenResponse.accessToken
        self.refreshToken = tokenResponse.refreshToken

        // Restore user if available
        if let user = tokenResponse.user {
            self.currentUser = user
            self.isAuthenticated = true
            self.authState = .loggedIn
            print("🔐 Session restored for: \(user.name)")

            // Sync timezone on app launch (user may have traveled)
            syncTimezone()

            // Optionally fetch fresh profile to ensure validity
            await fetchUserProfileAsync()
        } else {
            // Fetch user profile if not stored
            await fetchUserProfileAsync()
            // Only set logged in if we successfully got the user
            if self.currentUser != nil {
                self.authState = .loggedIn
                // Sync timezone after profile fetch
                syncTimezone()
            } else {
                print("🔐 Failed to fetch user profile, staying logged out")
                logout()
            }
        }
    }

    // MARK: - Timezone Sync

    /// Syncs the device's current timezone to the backend
    /// This ensures the backend uses the correct timezone for time formatting
    /// Called automatically after login and session restore
    open func syncTimezone() {
        let timezone = TimeZone.current.identifier
        print("🌍 Syncing timezone: \(timezone)")

        let request = TimezoneRequest(timezone: timezone)

        networkService.put(APIEndpoints.Users.timezone, body: request)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("⚠️ Failed to sync timezone: \(error.localizedDescription)")
                        // Non-critical error, don't show to user
                    }
                },
                receiveValue: { (response: APIResponse<EmptyResponse>) in
                    if response.success {
                        print("✅ Timezone synced successfully: \(timezone)")
                    } else {
                        print("⚠️ Timezone sync failed: \(response.message ?? "Unknown error")")
                    }
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Helper Functions

    /// Check if user is logged in
    open func isLoggedIn() -> Bool {
        return isAuthenticated && currentUser != nil
    }

    /// Check if user has a valid session
    open func hasValidSession() -> Bool {
        // Use cached token instead of Keychain read
        return accessToken != nil && !accessToken!.isEmpty
    }

    /// Clear current error
    open func clearError() {
        authError = nil
    }
}
