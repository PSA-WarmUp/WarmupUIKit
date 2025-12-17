//
//  APIResponse.swift
//  WarmupCore
//
//  Created by Shivkumar Loka on 12/17/25.
//
import Foundation

// MARK: - APIResponse
public struct APIResponse<T: Codable>: Codable {
    public let success: Bool
    public let message: String?
    public let data: T?
    public let page: Int?
    public let size: Int?
    public let totalElements: Int?
    public let totalPages: Int?

    // Additional fields for backend compatibility (optional, decoded but not required for init)
    public let errors: String?
    public let timestamp: String?
    public let path: String?

    // Convenience initializers for different scenarios
    public init(success: Bool, message: String? = nil, data: T? = nil) {
        self.success = success
        self.message = message
        self.data = data
        self.page = nil
        self.size = nil
        self.totalElements = nil
        self.totalPages = nil
        self.errors = nil
        self.timestamp = nil
        self.path = nil
    }

    public init(success: Bool, message: String? = nil, data: T? = nil,
         page: Int?, size: Int?, totalElements: Int?, totalPages: Int?) {
        self.success = success
        self.message = message
        self.data = data
        self.page = page
        self.size = size
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.errors = nil
        self.timestamp = nil
        self.path = nil
    }
}

// MARK: - Convenience Extensions
extension APIResponse {
    /// Check if the response is successful and has data
    public var isSuccessWithData: Bool {
        return success && data != nil
    }
}

// MARK: - PageResponse
public struct PageResponse<T: Codable>: Codable {
    public let content: [T]
    public let pageable: Pageable?
    public let totalElements: Int?
    public let totalPages: Int?
    public let last: Bool?
    public let first: Bool?
    public let numberOfElements: Int?
    public let size: Int?
    public let number: Int?
    public let empty: Bool?

    public init(content: [T], pageable: Pageable? = nil, totalElements: Int? = nil,
                totalPages: Int? = nil, last: Bool? = nil, first: Bool? = nil,
                numberOfElements: Int? = nil, size: Int? = nil, number: Int? = nil,
                empty: Bool? = nil) {
        self.content = content
        self.pageable = pageable
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.last = last
        self.first = first
        self.numberOfElements = numberOfElements
        self.size = size
        self.number = number
        self.empty = empty
    }
}

public struct Pageable: Codable {
    public let sort: Sort?
    public let offset: Int?
    public let pageNumber: Int?
    public let pageSize: Int?
    public let paged: Bool?
    public let unpaged: Bool?

    public init(sort: Sort? = nil, offset: Int? = nil, pageNumber: Int? = nil,
                pageSize: Int? = nil, paged: Bool? = nil, unpaged: Bool? = nil) {
        self.sort = sort
        self.offset = offset
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.paged = paged
        self.unpaged = unpaged
    }
}

public struct Sort: Codable {
    public let sorted: Bool?
    public let unsorted: Bool?
    public let empty: Bool?

    public init(sorted: Bool? = nil, unsorted: Bool? = nil, empty: Bool? = nil) {
        self.sorted = sorted
        self.unsorted = unsorted
        self.empty = empty
    }
}

// MARK: - APIError
public enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case networkError(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Unauthorized access"
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Empty Request/Response
public struct EmptyRequest: Codable {
    public init() {}
}

public struct EmptyResponse: Codable {
    public init() {}
}
