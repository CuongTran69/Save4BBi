//
//  PhotoService.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import UIKit
import Kingfisher
import RxSwift

/// Service for photo capture, compression, and storage
final class PhotoService {
    
    // MARK: - Singleton
    static let shared = PhotoService()
    
    // MARK: - Properties
    private let encryptionService = EncryptionService.shared
    private let fileManager = FileManager.default
    private let disposeBag = DisposeBag()
    
    // Photo storage directory
    private lazy var photosDirectory: URL = {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let photosPath = documentsPath.appendingPathComponent("EncryptedPhotos", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: photosPath.path) {
            try? fileManager.createDirectory(at: photosPath, withIntermediateDirectories: true)
        }
        
        return photosPath
    }()
    
    // MARK: - Initialization
    private init() {}
    
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
        
        // Calculate new size maintaining aspect ratio
        var newSize = size
        if size.width > maxWidth || size.height > maxHeight {
            let widthRatio = maxWidth / size.width
            let heightRatio = maxHeight / size.height
            let ratio = min(widthRatio, heightRatio)
            newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        }
        
        // Resize image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
    
    // MARK: - Photo Storage
    
    /// Save photo with encryption
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
                    .flatMap { encryptedData -> Observable<String> in
                        // 4. Generate unique filename
                        let filename = UUID().uuidString + ".enc"
                        let fileURL = self.photosDirectory.appendingPathComponent(filename)
                        
                        // 5. Save to disk
                        do {
                            try encryptedData.write(to: fileURL)
                            return Observable.just(filename)
                        } catch {
                            return Observable.error(PhotoError.saveFailed(error))
                        }
                    }
            }
    }
    
    /// Load and decrypt photo
    func loadPhoto(filename: String) -> Observable<UIImage> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(PhotoError.serviceUnavailable)
                return Disposables.create()
            }
            
            let fileURL = self.photosDirectory.appendingPathComponent(filename)
            
            // 1. Read encrypted data from disk
            guard let encryptedData = try? Data(contentsOf: fileURL) else {
                observer.onError(PhotoError.fileNotFound)
                return Disposables.create()
            }
            
            // 2. Decrypt data
            self.encryptionService.decryptPhoto(encryptedData)
                .subscribe(
                    onNext: { decryptedData in
                        // 3. Convert to UIImage
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
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
    
    /// Delete photo file
    func deletePhoto(filename: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(PhotoError.serviceUnavailable)
                return Disposables.create()
            }
            
            let fileURL = self.photosDirectory.appendingPathComponent(filename)
            
            do {
                try self.fileManager.removeItem(at: fileURL)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(PhotoError.deletionFailed(error))
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Errors
enum PhotoError: Error {
    case serviceUnavailable
    case compressionFailed
    case saveFailed(Error)
    case fileNotFound
    case invalidImageData
    case deletionFailed(Error)
    
    var localizedDescription: String {
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

