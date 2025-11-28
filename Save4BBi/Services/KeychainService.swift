//
//  KeychainService.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import Foundation
import KeychainAccess
import RxSwift

/// Service for secure storage of encryption keys and sensitive data
final class KeychainService {
    
    // MARK: - Singleton
    static let shared = KeychainService()
    
    // MARK: - Properties
    private let keychain: Keychain
    private let encryptionKeyIdentifier = "com.save4bbi.encryptionKey"
    
    // MARK: - Initialization
    private init() {
        // Create keychain with service identifier
        keychain = Keychain(service: "com.save4bbi.app")
            .accessibility(.whenUnlockedThisDeviceOnly)
    }
    
    // MARK: - Encryption Key Management
    
    /// Get or create encryption key for photo encryption
    func getOrCreateEncryptionKey() -> Observable<Data> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(KeychainError.serviceUnavailable)
                return Disposables.create()
            }
            
            do {
                // Try to retrieve existing key
                if let existingKey = try self.keychain.getData(self.encryptionKeyIdentifier) {
                    observer.onNext(existingKey)
                    observer.onCompleted()
                } else {
                    // Generate new 256-bit key for AES-256
                    let newKey = self.generateEncryptionKey()
                    try self.keychain.set(newKey, key: self.encryptionKeyIdentifier)
                    observer.onNext(newKey)
                    observer.onCompleted()
                }
            } catch {
                observer.onError(KeychainError.keyGenerationFailed(error))
            }
            
            return Disposables.create()
        }
    }
    
    /// Delete encryption key (use with caution - will make encrypted data unrecoverable)
    func deleteEncryptionKey() -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(KeychainError.serviceUnavailable)
                return Disposables.create()
            }
            
            do {
                try self.keychain.remove(self.encryptionKeyIdentifier)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(KeychainError.deletionFailed(error))
            }
            
            return Disposables.create()
        }
    }
    
    // MARK: - Generic Storage
    
    /// Save string value to keychain
    func save(string: String, forKey key: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                try self?.keychain.set(string, key: key)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(KeychainError.saveFailed(error))
            }
            return Disposables.create()
        }
    }
    
    /// Retrieve string value from keychain
    func getString(forKey key: String) -> Observable<String?> {
        return Observable.create { [weak self] observer in
            do {
                let value = try self?.keychain.get(key)
                observer.onNext(value)
                observer.onCompleted()
            } catch {
                observer.onError(KeychainError.retrievalFailed(error))
            }
            return Disposables.create()
        }
    }
    
    /// Delete value from keychain
    func delete(forKey key: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            do {
                try self?.keychain.remove(key)
                observer.onNext(())
                observer.onCompleted()
            } catch {
                observer.onError(KeychainError.deletionFailed(error))
            }
            return Disposables.create()
        }
    }
    
    // MARK: - Private Helpers
    
    private func generateEncryptionKey() -> Data {
        var keyData = Data(count: 32) // 256 bits
        _ = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        return keyData
    }
}

// MARK: - Errors
enum KeychainError: Error {
    case serviceUnavailable
    case keyGenerationFailed(Error)
    case saveFailed(Error)
    case retrievalFailed(Error)
    case deletionFailed(Error)
    
    var localizedDescription: String {
        switch self {
        case .serviceUnavailable:
            return "Keychain service is unavailable"
        case .keyGenerationFailed(let error):
            return "Failed to generate encryption key: \(error.localizedDescription)"
        case .saveFailed(let error):
            return "Failed to save to keychain: \(error.localizedDescription)"
        case .retrievalFailed(let error):
            return "Failed to retrieve from keychain: \(error.localizedDescription)"
        case .deletionFailed(let error):
            return "Failed to delete from keychain: \(error.localizedDescription)"
        }
    }
}

