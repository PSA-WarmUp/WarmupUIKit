//
//  NotificationService.swift
//  WarmupUIKit
//
//  Shared notification service for WarmUp iOS apps
//

import Foundation
import Combine

// MARK: - Notification Service

public class NotificationService {
    public static let shared = NotificationService()
    private let networkService = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {}

    // MARK: - Combine Publishers

    /// Fetches paginated list of notifications
    /// Note: Backend uses 0-indexed pages
    public func getNotificationsPublisher(page: Int = 0, limit: Int = 20) -> AnyPublisher<APIResponse<NotificationListResponse>, Error> {
        let url = "\(APIEndpoints.Notifications.list)?page=\(page)&size=\(limit)"
        return networkService.get(url)
    }

    /// Gets the count of unread notifications
    /// Note: Backend returns data as an integer directly, not wrapped in an object
    public func getUnreadCountPublisher() -> AnyPublisher<APIResponse<Int>, Error> {
        return networkService.get(APIEndpoints.Notifications.count)
    }

    /// Marks a single notification as read
    public func markAsReadPublisher(notificationId: String) -> AnyPublisher<APIResponse<EmptyResponse>, Error> {
        return networkService.post(APIEndpoints.Notifications.markRead(notificationId), body: EmptyResponse())
    }

    /// Marks all notifications as read
    public func markAllAsReadPublisher() -> AnyPublisher<APIResponse<EmptyResponse>, Error> {
        return networkService.post(APIEndpoints.Notifications.markAllRead, body: EmptyResponse())
    }

    // MARK: - Async Methods

    /// Fetches paginated list of notifications (async version)
    /// Note: Backend uses 0-indexed pages
    public func getNotifications(page: Int = 0, limit: Int = 20) async throws -> NotificationListResponse {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getNotificationsPublisher(page: page, limit: limit)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        if let data = response.data {
                            continuation.resume(returning: data)
                        } else {
                            continuation.resume(returning: NotificationListResponse())
                        }
                    }
                )
        }
    }

    /// Gets the count of unread notifications (async version)
    public func getUnreadCount() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getUnreadCountPublisher()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { response in
                        // data is now directly an Int
                        continuation.resume(returning: response.data ?? 0)
                    }
                )
        }
    }

    /// Marks a single notification as read (async version)
    public func markAsRead(notificationId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = markAsReadPublisher(notificationId: notificationId)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in }
                )
        }
    }

    /// Marks all notifications as read (async version)
    public func markAllAsRead() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = markAllAsReadPublisher()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { _ in }
                )
        }
    }

    // MARK: - Device Token

    /// Registers device token for push notifications
    public func registerDeviceToken(_ token: String) async throws {
        // TODO: Implement when push notifications are needed
    }

    /// Removes device token
    public func removeDeviceToken(_ tokenId: String) async throws {
        // TODO: Implement when push notifications are needed
    }
}
