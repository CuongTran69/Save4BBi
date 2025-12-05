//
//  Services.swift
//  MediFamily
//
//  Created by Cường Trần on 20/11/25.
//

import Foundation

/// Central access point for all services
struct Services {
    
    /// Keychain service for secure storage
    static var keychain: KeychainService {
        return KeychainService.shared
    }
    
    /// Encryption service for data security
    static var encryption: EncryptionService {
        return EncryptionService.shared
    }
    
    /// Photo service for image processing
    static var photo: PhotoService {
        return PhotoService.shared
    }
    
    /// Biometric authentication service
    static var biometric: BiometricService {
        return BiometricService.shared
    }
}

