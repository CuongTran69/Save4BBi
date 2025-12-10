//
//  EncryptionService.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import Foundation
import CryptoKit
import RxSwift

/// Service for encrypting and decrypting photos and sensitive data
final class EncryptionService {
    
    // MARK: - Singleton
    static let shared = EncryptionService()
    
    // MARK: - Properties
    private let keychainService = KeychainService.shared
    private let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Photo Encryption

    /// Encrypt photo data using AES-256-GCM
    func encryptPhoto(_ photoData: Data) -> Observable<Data> {
        return keychainService.getOrCreateEncryptionKey()
            .flatMap { key -> Observable<Data> in
                return Observable.create { observer in
                    do {
                        // Create symmetric key from raw key data
                        let symmetricKey = SymmetricKey(data: key)

                        // Encrypt using AES-GCM (authenticated encryption)
                        let sealedBox = try AES.GCM.seal(photoData, using: symmetricKey)

                        // Get combined data (nonce + ciphertext + tag)
                        guard let encryptedData = sealedBox.combined else {
                            observer.onError(EncryptionError.encryptionFailed(NSError(domain: "EncryptionService", code: -1)))
                            return Disposables.create()
                        }

                        observer.onNext(encryptedData)
                        observer.onCompleted()
                    } catch {
                        observer.onError(EncryptionError.encryptionFailed(error))
                    }

                    return Disposables.create()
                }
            }
    }
    
    /// Decrypt photo data using AES-256-GCM
    func decryptPhoto(_ encryptedData: Data) -> Observable<Data> {
        return keychainService.getOrCreateEncryptionKey()
            .flatMap { key -> Observable<Data> in
                return Observable.create { observer in
                    do {
                        // Create symmetric key from raw key data
                        let symmetricKey = SymmetricKey(data: key)

                        // Create sealed box from combined data
                        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)

                        // Decrypt and verify
                        let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)

                        observer.onNext(decryptedData)
                        observer.onCompleted()
                    } catch {
                        observer.onError(EncryptionError.decryptionFailed(error))
                    }

                    return Disposables.create()
                }
            }
    }
    
    // MARK: - String Encryption (for metadata)
    
    /// Encrypt string data
    func encryptString(_ string: String) -> Observable<String> {
        guard let data = string.data(using: .utf8) else {
            return Observable.error(EncryptionError.invalidString)
        }
        
        return encryptPhoto(data)
            .map { $0.base64EncodedString() }
    }
    
    /// Decrypt string data
    func decryptString(_ encryptedString: String) -> Observable<String> {
        guard let data = Data(base64Encoded: encryptedString) else {
            return Observable.error(EncryptionError.invalidData)
        }
        
        return decryptPhoto(data)
            .flatMap { decryptedData -> Observable<String> in
                guard let string = String(data: decryptedData, encoding: .utf8) else {
                    return Observable.error(EncryptionError.invalidString)
                }
                return Observable.just(string)
            }
    }
    
    // MARK: - Hash (for verification)

    /// Generate SHA-256 hash of data
    func hash(_ data: Data) -> String {
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    /// Verify data integrity using hash
    func verifyHash(_ data: Data, expectedHash: String) -> Bool {
        let actualHash = hash(data)
        return actualHash == expectedHash
    }
}

// MARK: - Errors
enum EncryptionError: LocalizedError {
    case encryptionFailed(Error)
    case decryptionFailed(Error)
    case invalidData
    case invalidString
    case keyNotFound

    var errorDescription: String? {
        switch self {
        case .encryptionFailed(let error):
            return "Encryption failed: \(error.localizedDescription)"
        case .decryptionFailed(let error):
            return "Decryption failed: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid encrypted data format"
        case .invalidString:
            return "Invalid string encoding"
        case .keyNotFound:
            return "Encryption key not found"
        }
    }
}

