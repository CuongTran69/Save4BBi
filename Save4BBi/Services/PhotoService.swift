//
//  PhotoService.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import UIKit
import Kingfisher
import RxSwift

/// Service for photo capture, compression, and storage
/// Thread-safe singleton for managing encrypted photo storage
final class PhotoService {

    // MARK: - Singleton
    static let shared = PhotoService()

    // MARK: - Properties
    private let encryptionService = EncryptionService.shared
    private let fileManager = FileManager.default

    /// Serial queue for thread-safe file operations
    private let fileOperationQueue = DispatchQueue(label: "com.mediFamily.photoService", qos: .userInitiated)

    // Photo storage directory (lazily initialized, thread-safe via serial queue)
    private var _photosDirectory: URL?
    private var photosDirectory: URL {
        if let dir = _photosDirectory {
            return dir
        }

        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("EncryptedPhotos", isDirectory: true)

        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: photosPath.path) {
            try? fileManager.createDirectory(at: photosPath, withIntermediateDirectories: true)
        }

        _photosDirectory = photosPath
        return photosPath
    }

    // MARK: - Initialization
    private init() {
        // Pre-initialize the photos directory on the serial queue
        fileOperationQueue.async { [weak self] in
            _ = self?.photosDirectory
        }
    }
    
    // MARK: - Photo Processing
    
    /// Compress image to target size (default 1MB)
    func compressImage(_ image: UIImage, targetSizeKB: Int = 1024) -> Observable<Data> {
        return Observable.create { observer in
            DispatchQueue.global(qos: .userInitiated).async {
                var compression: CGFloat = 1.0
                var imageData = image.jpegData(compressionQuality: compression)
                
                let targetBytes = targetSizeKB * 1024
                
                // Reduce quality until target size is reached
                while let data = imageData, data.count > targetBytes && compression > 0.1 {
                    compression -= 0.1
                    imageData = image.jpegData(compressionQuality: compression)
                }
                
                if let finalData = imageData {
                    observer.onNext(finalData)
                    observer.onCompleted()
                } else {
                    observer.onError(PhotoError.compressionFailed)
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Resize image to maximum dimensions
    func resizeImage(_ image: UIImage, maxWidth: CGFloat = 1920, maxHeight: CGFloat = 1920) -> UIImage {
        let size = image.size

        // Skip resize if already within bounds
        guard size.width > maxWidth || size.height > maxHeight else {
            return image
        }

        // Calculate new size maintaining aspect ratio
        let widthRatio = maxWidth / size.width
        let heightRatio = maxHeight / size.height
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        // Use modern UIGraphicsImageRenderer (iOS 10+)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: newSize, format: format)

        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    // MARK: - Photo Storage

    /// Save photo with encryption (thread-safe)
    func savePhoto(_ image: UIImage) -> Observable<String> {
        // 1. Resize image
        let resizedImage = resizeImage(image)

        // 2. Compress image
        return compressImage(resizedImage)
            .flatMap { [weak self] imageData -> Observable<String> in
                guard let self = self else {
                    return Observable.error(PhotoError.serviceUnavailable)
                }

                // 3. Encrypt image data
                return self.encryptionService.encryptPhoto(imageData)
                    .flatMap { [weak self] encryptedData -> Observable<String> in
                        guard let self = self else {
                            return Observable.error(PhotoError.serviceUnavailable)
                        }

                        // 4. Save to disk on serial queue for thread safety
                        return Observable.create { observer in
                            self.fileOperationQueue.async {
                                let filename = UUID().uuidString + ".enc"
                                let fileURL = self.photosDirectory.appendingPathComponent(filename)

                                do {
                                    try encryptedData.write(to: fileURL)
                                    observer.onNext(filename)
                                    observer.onCompleted()
                                } catch {
                                    observer.onError(PhotoError.saveFailed(error))
                                }
                            }
                            return Disposables.create()
                        }
                    }
            }
    }

    /// Load and decrypt photo (thread-safe)
    func loadPhoto(filename: String) -> Observable<UIImage> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(PhotoError.serviceUnavailable)
                return Disposables.create()
            }

            // Read file on serial queue for thread safety
            self.fileOperationQueue.async {
                let fileURL = self.photosDirectory.appendingPathComponent(filename)

                guard let encryptedData = try? Data(contentsOf: fileURL) else {
                    observer.onError(PhotoError.fileNotFound)
                    return
                }

                // Decrypt and return image
                _ = self.encryptionService.decryptPhoto(encryptedData)
                    .subscribe(
                        onNext: { decryptedData in
                            if let image = UIImage(data: decryptedData) {
                                observer.onNext(image)
                                observer.onCompleted()
                            } else {
                                observer.onError(PhotoError.invalidImageData)
                            }
                        },
                        onError: { error in
                            observer.onError(error)
                        }
                    )
            }
            return Disposables.create()
        }
    }

    /// Delete photo file (thread-safe)
    func deletePhoto(filename: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(PhotoError.serviceUnavailable)
                return Disposables.create()
            }

            // Delete file on serial queue for thread safety
            self.fileOperationQueue.async {
                let fileURL = self.photosDirectory.appendingPathComponent(filename)

                do {
                    try self.fileManager.removeItem(at: fileURL)
                    observer.onNext(())
                    observer.onCompleted()
                } catch {
                    observer.onError(PhotoError.deletionFailed(error))
                }
            }

            return Disposables.create()
        }
    }
}

// MARK: - Errors
enum PhotoError: LocalizedError {
    case serviceUnavailable
    case compressionFailed
    case saveFailed(Error)
    case fileNotFound
    case invalidImageData
    case deletionFailed(Error)

    var errorDescription: String? {
        switch self {
        case .serviceUnavailable:
            return "Photo service is unavailable"
        case .compressionFailed:
            return "Failed to compress image"
        case .saveFailed(let error):
            return "Failed to save photo: \(error.localizedDescription)"
        case .fileNotFound:
            return "Photo file not found"
        case .invalidImageData:
            return "Invalid image data"
        case .deletionFailed(let error):
            return "Failed to delete photo: \(error.localizedDescription)"
        }
    }
}

