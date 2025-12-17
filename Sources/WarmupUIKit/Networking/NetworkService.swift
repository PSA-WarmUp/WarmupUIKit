//
//  NetworkService.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 12/17/25.
//

import Foundation
import Combine

public class NetworkService {

    // MARK: - Singleton
    public static let shared = NetworkService()

    // MARK: - Properties
    private let session: URLSession
    private let keychain = KeychainHelper()
    private var cancellables = Set<AnyCancellable>()

    // Configuration
    public var baseURL: String = ""
    public var enableLogging: Bool = false
    public var enableVerboseNetworking: Bool = false

    // Token refresh callback (for app-level handling)
    public var onSessionExpired: (() -> Void)?
    public var onTokenRefreshed: ((String, String) -> Void)?

    // MARK: - Initialization
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true

        self.session = URLSession(configuration: config)

        if enableLogging {
            print("🌐 NetworkService initialized")
        }
    }

    // MARK: - Public API Methods

    /// GET request
    public func get<T: Decodable>(
        _ endpoint: String,
        requiresAuth: Bool = true
    ) -> AnyPublisher<APIResponse<T>, Error> {
        return makeRequest(
            endpoint: endpoint,
            method: .GET,
            body: nil as Data?,
            requiresAuth: requiresAuth
        )
    }

    /// POST request with body
    public func post<T: Decodable, U: Encodable>(
        _ endpoint: String,
        body: U,
        requiresAuth: Bool = true
    ) -> AnyPublisher<APIResponse<T>, Error> {
        return makeRequest(
            endpoint: endpoint,
            method: .POST,
            body: body,
            requiresAuth: requiresAuth
        )
    }

    /// PUT request with body
    public func put<T: Decodable, U: Encodable>(
        _ endpoint: String,
        body: U,
        requiresAuth: Bool = true
    ) -> AnyPublisher<APIResponse<T>, Error> {
        return makeRequest(
            endpoint: endpoint,
            method: .PUT,
            body: body,
            requiresAuth: requiresAuth
        )
    }

    /// PATCH request with body
    public func patch<T: Decodable, U: Encodable>(
        _ endpoint: String,
        body: U,
        requiresAuth: Bool = true
    ) -> AnyPublisher<APIResponse<T>, Error> {
        return makeRequest(
            endpoint: endpoint,
            method: .PATCH,
            body: body,
            requiresAuth: requiresAuth
        )
    }

    /// DELETE request
    public func delete<T: Decodable>(
        _ endpoint: String,
        requiresAuth: Bool = true
    ) -> AnyPublisher<APIResponse<T>, Error> {
        return makeRequest(
            endpoint: endpoint,
            method: .DELETE,
            body: nil as Data?,
            requiresAuth: requiresAuth
        )
    }

    // MARK: - Core Request Method

    private func makeRequest<T: Decodable, U: Encodable>(
        endpoint: String,
        method: HTTPMethod,
        body: U?,
        requiresAuth: Bool
    ) -> AnyPublisher<APIResponse<T>, Error> {

        // Build URL
        guard let url = buildURL(for: endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        // Build Request
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("iOS", forHTTPHeaderField: "X-Platform")

        // Add body if provided
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return Fail(error: NetworkError.encodingError(error.localizedDescription))
                    .eraseToAnyPublisher()
            }
        }

        // Add authorization header if required
        if requiresAuth {
            // Read token from keychain
            if let token = keychain.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

                if enableVerboseNetworking {
                    print("🔑 Added auth token: \(String(token.prefix(20)))...")
                }
            } else {
                if enableLogging {
                    print("⚠️ No auth token available for protected endpoint: \(endpoint)")
                }
                // For protected endpoints, fail fast if no token
                return Fail(error: NetworkError.noAuthToken).eraseToAnyPublisher()
            }
        }

        // Log request
        if enableVerboseNetworking {
            logRequest(request)
        }

        // Perform request
        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                // Log response
                if self?.enableVerboseNetworking == true {
                    self?.logResponse(data, statusCode: httpResponse.statusCode)
                }

                // Handle different status codes
                switch httpResponse.statusCode {
                case 200...299:
                    return data

                case 401:
                    if requiresAuth {
                        // Token might be expired
                        throw NetworkError.unauthorized
                    } else {
                        // Login failed
                        throw NetworkError.invalidCredentials
                    }

                case 403:
                    throw NetworkError.forbidden

                case 404:
                    throw NetworkError.notFound

                case 400...499:
                    // Try to parse error message from response
                    if let errorResponse = try? JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data) {
                        throw NetworkError.serverError(errorResponse.message ?? "Client error")
                    }
                    throw NetworkError.badRequest

                case 500...599:
                    throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")

                default:
                    throw NetworkError.unknownError
                }
            }
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .tryCatch { [weak self] error -> AnyPublisher<APIResponse<T>, Error> in
                // If unauthorized and we have a refresh token, try to refresh
                if case NetworkError.unauthorized = error,
                   requiresAuth,
                   let refreshToken = self?.keychain.getRefreshToken() {
                    return self?.refreshAndRetry(
                        originalEndpoint: endpoint,
                        method: method,
                        body: body,
                        refreshToken: refreshToken
                    ) ?? Fail(error: error).eraseToAnyPublisher()
                }

                // For other errors, just pass them through
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Token Refresh

    private func refreshAndRetry<T: Decodable, U: Encodable>(
        originalEndpoint: String,
        method: HTTPMethod,
        body: U?,
        refreshToken: String
    ) -> AnyPublisher<APIResponse<T>, Error> {

        if enableLogging {
            print("🔄 Attempting token refresh...")
        }

        let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)

        // Call refresh endpoint without auth
        return post(APIEndpoints.Auth.refresh, body: refreshRequest, requiresAuth: false)
            .flatMap { [weak self] (response: APIResponse<TokenResponse>) -> AnyPublisher<APIResponse<T>, Error> in
                guard let self = self else {
                    return Fail(error: NetworkError.unknownError).eraseToAnyPublisher()
                }

                guard response.success, let tokenResponse = response.data else {
                    // Refresh failed, user needs to login again
                    // Notify via callback
                    Task { @MainActor in
                        self.onSessionExpired?()
                    }
                    return Fail(error: NetworkError.sessionExpired).eraseToAnyPublisher()
                }

                // Save new tokens directly to keychain
                _ = self.keychain.saveTokenResponse(tokenResponse)

                // Notify via callback
                Task { @MainActor in
                    self.onTokenRefreshed?(tokenResponse.accessToken, tokenResponse.refreshToken)
                }

                if self.enableLogging {
                    print("✅ Token refreshed successfully")
                }

                // Retry original request with new token
                return self.makeRequest(
                    endpoint: originalEndpoint,
                    method: method,
                    body: body,
                    requiresAuth: true
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - JSON Dictionary POST

    public func postJSON<T: Decodable>(
        _ endpoint: String,
        body: [String: Any],
        requiresAuth: Bool = true
    ) -> AnyPublisher<APIResponse<T>, Error> {

        guard let url = buildURL(for: endpoint) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("iOS", forHTTPHeaderField: "X-Platform")

        // Add auth if required
        if requiresAuth {
            if let token = keychain.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                if enableVerboseNetworking {
                    print("🔑 Added auth token: \(token.prefix(20))...")
                }
            } else if requiresAuth {
                return Fail(error: NetworkError.noAuthToken).eraseToAnyPublisher()
            }
        }

        // Convert dictionary to JSON data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return Fail(error: NetworkError.encodingError("Failed to serialize JSON: \(error.localizedDescription)"))
                .eraseToAnyPublisher()
        }

        // Log request if in debug mode
        if enableLogging {
            logRequest(request)
        }

        return session.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                // Log response
                if self?.enableLogging == true {
                    self?.logResponse(data, statusCode: httpResponse.statusCode)
                }

                // Check status code
                switch httpResponse.statusCode {
                case 200...299:
                    return data

                case 400:
                    // Try to decode error response for better error message
                    if let errorResponse = try? JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data) {
                        throw NetworkError.serverError(errorResponse.message ?? "Validation failed")
                    }
                    throw NetworkError.badRequest

                case 401:
                    throw NetworkError.unauthorized

                case 403:
                    throw NetworkError.forbidden

                case 404:
                    throw NetworkError.notFound

                case 500...599:
                    throw NetworkError.serverError("Server error: \(httpResponse.statusCode)")

                default:
                    throw NetworkError.unknownError
                }
            }
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }

    // MARK: - Multipart Upload

    private var uploadSession: URLSession {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 600
        config.allowsCellularAccess = true
        config.allowsExpensiveNetworkAccess = true
        config.allowsConstrainedNetworkAccess = true
        return URLSession(configuration: config, delegate: nil, delegateQueue: .main)
    }

    @MainActor
    public func uploadMultipart<T: Decodable>(
        _ endpoint: String,
        body: Data,
        boundary: String,
        progressHandler: @escaping (Double) -> Void = { _ in }
    ) -> AnyPublisher<APIResponse<T>, Error> {

        guard let url = URL(string: endpoint) else {
            return Fail(error: NetworkError.invalidURL)
                .eraseToAnyPublisher()
        }

        if enableVerboseNetworking {
            print("🔍 Full URL: \(url)")
            print("📦 Body size: \(body.count) bytes")
            print("🎭 Boundary: \(boundary)")
            if let bodyString = String(data: body.prefix(500), encoding: .utf8) {
                print("📝 Body preview: \(bodyString)")
            }
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Use keychain for auth
        if let accessToken = keychain.getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        return Future<APIResponse<T>, Error> { [weak self] promise in
            guard let self = self else { return }
            let task = self.uploadSession.uploadTask(with: request, from: body) { [weak self] data, response, error in
                Task { @MainActor in
                    if let error = error {
                        promise(.failure(NetworkError.serverError(error.localizedDescription)))
                        return
                    }

                    guard let httpResponse = response as? HTTPURLResponse else {
                        promise(.failure(NetworkError.invalidResponse))
                        return
                    }

                    if self?.enableVerboseNetworking == true {
                        print("📡 Response Status: \(httpResponse.statusCode)")
                        print("📡 Response Headers: \(httpResponse.allHeaderFields)")
                    }

                    // Handle 401 - call session expired callback
                    if httpResponse.statusCode == 401 {
                        self?.onSessionExpired?()
                        promise(.failure(NetworkError.unauthorized))
                        return
                    }

                    self?.handleUploadResponse(
                        data: data,
                        response: response,
                        error: error,
                        promise: promise
                    )
                }
            }

            // Track upload progress
            task.progress.publisher(for: \.fractionCompleted, options: [.new])
                .removeDuplicates()
                .sink { fraction in
                    progressHandler(fraction)
                }
                .store(in: &self.cancellables)

            task.resume()
        }
        .eraseToAnyPublisher()
    }


    @MainActor
    private func handleUploadResponse<T: Decodable>(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        promise: @escaping (Result<APIResponse<T>, Error>) -> Void
    ) {
        if let error = error {
            promise(.failure(NetworkError.serverError(error.localizedDescription)))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            promise(.failure(NetworkError.invalidResponse))
            return
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to parse error message from response
            if let data = data,
               let errorResponse = try? JSONDecoder().decode(APIResponse<T>.self, from: data) {
                promise(.failure(NetworkError.serverError(errorResponse.message ?? "Status: \(httpResponse.statusCode)")))
            } else {
                promise(.failure(NetworkError.serverError("Status: \(httpResponse.statusCode)")))
            }
            return
        }

        guard let data = data else {
            promise(.failure(NetworkError.invalidResponse))
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
            promise(.success(apiResponse))
        } catch {
            promise(.failure(NetworkError.decodingError))
        }
    }

    // MARK: - Helper Methods

    private func buildURL(for endpoint: String) -> URL? {
        // If endpoint is already a full URL, use it
        if endpoint.starts(with: "http") {
            return URL(string: endpoint)
        }

        // Otherwise, combine with base URL
        let fullURLString = baseURL + endpoint
        return URL(string: fullURLString)
    }

    private func logRequest(_ request: URLRequest) {
        print("\n🌐 ➡️ REQUEST: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "Unknown")")

        if let headers = request.allHTTPHeaderFields {
            print("   📋 Headers: \(headers)")
        }

        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            // Truncate long bodies for readability
            let truncated = bodyString.count > 500 ? String(bodyString.prefix(500)) + "..." : bodyString
            print("   📦 Body: \(truncated)")
        }
    }

    private func logResponse(_ data: Data, statusCode: Int) {
        print("\n🌐 ⬅️ RESPONSE: Status \(statusCode)")

        if let responseString = String(data: data, encoding: .utf8) {
            // Truncate long responses for readability
            let truncated = responseString.count > 500 ? String(responseString.prefix(500)) + "..." : responseString
            print("   📦 Response: \(truncated)")
        }
    }
}

// MARK: - HTTP Method Enum
public enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

// MARK: - Network Errors
public enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
    case encodingError(String)
    case unauthorized
    case forbidden
    case notFound
    case badRequest
    case invalidCredentials
    case serverError(String)
    case noAuthToken
    case sessionExpired
    case noRefreshToken
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .encodingError(let message):
            return "Failed to encode request: \(message)"
        case .unauthorized:
            return "Unauthorized. Please login again."
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .badRequest:
            return "Invalid request"
        case .invalidCredentials:
            return "Invalid email or password"
        case .serverError(let message):
            return message
        case .noAuthToken:
            return "Authentication required"
        case .sessionExpired:
            return "Your session has expired. Please login again."
        case .noRefreshToken:
            return "No refresh token available"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Data Extension
public extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }

    mutating func appendString(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

// MARK: - Supporting Types
// Note: EmptyResponse, RefreshTokenRequest, TokenResponse, and APIResponse
// are defined in Models/API/APIResponse.swift and Models/Auth/TokenResponse.swift
