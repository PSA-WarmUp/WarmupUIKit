//
//  MediaService.swift
//  WarmupUIKit
//
//  Media upload/download service for handling S3 presigned URLs
//

import Foundation
import Combine
import UIKit

// MARK: - Upload URL Response

public struct UploadUrlResponse: Codable {
    public let uploadUrl: String
    public let fileName: String
    public let directUpload: Bool

    public init(uploadUrl: String, fileName: String, directUpload: Bool) {
        self.uploadUrl = uploadUrl
        self.fileName = fileName
        self.directUpload = directUpload
    }
}

// MARK: - Media Service

public class MediaService {
    public static let shared = MediaService()

    private let networkService = NetworkService.shared

    public init() {}

    /// Get a presigned upload URL for a file
    /// - Parameters:
    ///   - fileName: Name of the file to upload
    ///   - contentType: MIME type of the file (default: application/octet-stream)
    /// - Returns: Publisher with upload URL response
    public func getUploadUrl(
        fileName: String,
        contentType: String = "application/octet-stream"
    ) -> AnyPublisher<UploadUrlResponse?, Error> {
        let encodedFileName = fileName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fileName
        let encodedContentType = contentType.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? contentType
        let endpoint = "\(APIEndpoints.Media.upload)?fileName=\(encodedFileName)&contentType=\(encodedContentType)"

        return networkService.get(endpoint)
            .map { (response: APIResponse<UploadUrlResponse>) -> UploadUrlResponse? in
                response.data
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    /// Get a presigned download URL for a file
    /// - Parameter key: The S3 key of the file
    /// - Returns: Publisher with download URL string
    public func getDownloadUrl(key: String) -> AnyPublisher<String?, Error> {
        let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
        let endpoint = "\(APIEndpoints.Media.download)?key=\(encodedKey)"

        return networkService.get(endpoint)
            .map { (response: APIResponse<[String: String]>) -> String? in
                response.data?["downloadUrl"]
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }

    /// Upload image data to a presigned URL
    /// - Parameters:
    ///   - data: Image data to upload
    ///   - uploadUrl: The presigned upload URL
    ///   - contentType: MIME type of the image
    /// - Returns: Publisher indicating success/failure
    public func uploadToPresignedUrl(
        data: Data,
        uploadUrl: String,
        contentType: String = "image/jpeg"
    ) -> AnyPublisher<Bool, Error> {
        guard let url = URL(string: uploadUrl) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        request.httpBody = data

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { _, response in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError("Upload failed")
                }
                return true
            }
            .eraseToAnyPublisher()
    }

    /// Convenience method to get upload URL and upload image in one call
    /// - Parameters:
    ///   - imageData: Image data to upload
    ///   - fileName: Name for the file
    ///   - contentType: MIME type (default: image/jpeg)
    /// - Returns: Publisher with the file key/name on success
    public func uploadImage(
        imageData: Data,
        fileName: String,
        contentType: String = "image/jpeg"
    ) -> AnyPublisher<String, Error> {
        getUploadUrl(fileName: fileName, contentType: contentType)
            .flatMap { [weak self] response -> AnyPublisher<String, Error> in
                guard let self = self,
                      let uploadResponse = response else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }

                return self.uploadToPresignedUrl(
                    data: imageData,
                    uploadUrl: uploadResponse.uploadUrl,
                    contentType: contentType
                )
                .map { _ in uploadResponse.fileName }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - Image Compression Helpers

public extension MediaService {
    /// Compress an image to JPEG with specified quality
    /// - Parameters:
    ///   - image: UIImage to compress
    ///   - quality: Compression quality (0.0 to 1.0)
    ///   - maxDimension: Maximum width/height dimension
    /// - Returns: Compressed JPEG data
    static func compressImage(
        _ image: UIImage,
        quality: CGFloat = 0.8,
        maxDimension: CGFloat = 1024
    ) -> Data? {
        // Resize if needed
        let resizedImage: UIImage
        if image.size.width > maxDimension || image.size.height > maxDimension {
            let scale = min(maxDimension / image.size.width, maxDimension / image.size.height)
            let newSize = CGSize(
                width: image.size.width * scale,
                height: image.size.height * scale
            )
            let renderer = UIGraphicsImageRenderer(size: newSize)
            resizedImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
        } else {
            resizedImage = image
        }

        return resizedImage.jpegData(compressionQuality: quality)
    }

    /// Generate a unique filename for an image upload
    /// - Parameter prefix: Optional prefix for the filename
    /// - Returns: Unique filename with .jpg extension
    static func generateImageFileName(prefix: String = "image") -> String {
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        let uuid = UUID().uuidString.prefix(8)
        return "\(prefix)_\(timestamp)_\(uuid).jpg"
    }
}
