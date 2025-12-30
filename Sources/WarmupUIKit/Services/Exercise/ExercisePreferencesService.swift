//
//  ExercisePreferencesService.swift
//  WarmupUIKit
//
//  Shared service for exercise preferences, favorites, recent exercises, and smart defaults
//

import Foundation
import Combine

// MARK: - Quick Add Exercise Request

public struct QuickAddExerciseRequest: Codable, Sendable {
    public let name: String
    public let category: String?
    public let equipment: String?

    public init(name: String, category: String? = nil, equipment: String? = nil) {
        self.name = name
        self.category = category
        self.equipment = equipment
    }
}

// MARK: - Exercise Preferences Service

public class ExercisePreferencesService {
    public static let shared = ExercisePreferencesService()
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    // MARK: - Recent Exercises

    /// Fetches trainer's recently used exercises
    /// - Parameter limit: Maximum number of exercises to return (default 20)
    /// - Returns: Publisher with array of recent exercises
    public func getRecentExercisesPublisher(limit: Int = 20) -> AnyPublisher<APIResponse<[RecentExercise]>, Error> {
        let url = "\(APIEndpoints.Exercises.recent)?limit=\(limit)"
        return networkService.get(url)
    }

    /// Fetches trainer's recently used exercises (async version)
    public func getRecentExercises(limit: Int = 20) async throws -> [RecentExercise] {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getRecentExercisesPublisher(limit: limit)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        continuation.resume(returning: response.data ?? [])
                    }
                )
        }
    }

    // MARK: - Favorites

    /// Fetches trainer's favorite exercises
    public func getFavoriteExercisesPublisher() -> AnyPublisher<APIResponse<[Exercise]>, Error> {
        return networkService.get(APIEndpoints.Exercises.favorites)
    }

    /// Fetches trainer's favorite exercises (async version)
    public func getFavoriteExercises() async throws -> [Exercise] {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getFavoriteExercisesPublisher()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        continuation.resume(returning: response.data ?? [])
                    }
                )
        }
    }

    /// Adds an exercise to favorites
    public func addFavoritePublisher(_ exerciseId: String) -> AnyPublisher<APIResponse<EmptyResponse>, Error> {
        return networkService.post(APIEndpoints.Exercises.addFavorite(exerciseId), body: EmptyRequest())
    }

    /// Adds an exercise to favorites (async version)
    public func addFavorite(_ exerciseId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = addFavoritePublisher(exerciseId)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in }
                )
        }
    }

    /// Removes an exercise from favorites
    public func removeFavoritePublisher(_ exerciseId: String) -> AnyPublisher<APIResponse<EmptyResponse>, Error> {
        return networkService.delete(APIEndpoints.Exercises.removeFavorite(exerciseId))
    }

    /// Removes an exercise from favorites (async version)
    public func removeFavorite(_ exerciseId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = removeFavoritePublisher(exerciseId)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in }
                )
        }
    }

    // MARK: - Smart Defaults

    /// Fetches smart defaults for an exercise
    /// - Parameters:
    ///   - exerciseId: The exercise ID
    ///   - clientId: Optional client ID for client-specific defaults
    public func getSmartDefaultsPublisher(exerciseId: String, clientId: String? = nil) -> AnyPublisher<APIResponse<SmartDefaults>, Error> {
        let url: String
        if let clientId = clientId {
            url = APIEndpoints.Exercises.smartDefaultsForClient(exerciseId, clientId: clientId)
        } else {
            url = APIEndpoints.Exercises.smartDefaults(exerciseId)
        }
        return networkService.get(url)
    }

    /// Fetches smart defaults for an exercise (async version)
    public func getSmartDefaults(exerciseId: String, clientId: String? = nil) async throws -> SmartDefaults {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getSmartDefaultsPublisher(exerciseId: exerciseId, clientId: clientId)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        continuation.resume(returning: response.data ?? SmartDefaults.fallback)
                    }
                )
        }
    }

    // MARK: - Record Usage

    /// Records exercise usage for smart defaults calculation
    public func recordUsagePublisher(_ exerciseId: String, request: RecordExerciseUsageRequest) -> AnyPublisher<APIResponse<EmptyResponse>, Error> {
        return networkService.post(APIEndpoints.Exercises.recordUsage(exerciseId), body: request)
    }

    /// Records exercise usage (async version)
    public func recordUsage(_ exerciseId: String, request: RecordExerciseUsageRequest) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = recordUsagePublisher(exerciseId, request: request)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in }
                )
        }
    }

    // MARK: - Quick Add Exercise

    /// Creates a minimal custom exercise (quick add)
    public func quickAddExercisePublisher(_ request: QuickAddExerciseRequest) -> AnyPublisher<APIResponse<Exercise>, Error> {
        return networkService.post(APIEndpoints.Exercises.quickAdd, body: request)
    }

    /// Creates a minimal custom exercise (async version)
    public func quickAddExercise(_ request: QuickAddExerciseRequest) async throws -> Exercise {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = quickAddExercisePublisher(request)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        if let exercise = response.data {
                            continuation.resume(returning: exercise)
                        } else {
                            continuation.resume(throwing: ExercisePreferencesError.noData)
                        }
                    }
                )
        }
    }

    // MARK: - Trainer Preferences

    /// Fetches trainer's workout preferences
    public func getTrainerPreferencesPublisher() -> AnyPublisher<APIResponse<TrainerExercisePreferences>, Error> {
        return networkService.get(APIEndpoints.TrainerPreferences.me)
    }

    /// Fetches trainer's workout preferences (async version)
    public func getTrainerPreferences() async throws -> TrainerExercisePreferences {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getTrainerPreferencesPublisher()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        if let preferences = response.data {
                            continuation.resume(returning: preferences)
                        } else {
                            continuation.resume(throwing: ExercisePreferencesError.noData)
                        }
                    }
                )
        }
    }

    /// Updates trainer's workout preferences
    public func updateTrainerPreferencesPublisher(_ request: UpdateTrainerPreferencesRequest) -> AnyPublisher<APIResponse<EmptyResponse>, Error> {
        return networkService.put(APIEndpoints.TrainerPreferences.me, body: request)
    }

    /// Updates trainer's workout preferences (async version)
    public func updateTrainerPreferences(_ request: UpdateTrainerPreferencesRequest) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = updateTrainerPreferencesPublisher(request)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in }
                )
        }
    }
}

// MARK: - Error Types

public enum ExercisePreferencesError: LocalizedError {
    case noData
    case networkError(Error)
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .noData:
            return "No data returned from server"
        case .networkError(let error):
            return error.localizedDescription
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

