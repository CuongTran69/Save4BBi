//
//  BiometricService.swift
//  Save4BBi
//
//  Created by Cường Trần on 20/11/25.
//

import Foundation
import LocalAuthentication
import RxSwift

/// Service for biometric authentication (Face ID / Touch ID)
final class BiometricService {

    // MARK: - Singleton
    static let shared = BiometricService()

    // MARK: - Initialization
    private init() {}

    // MARK: - Biometric Type

    enum BiometricType {
        case none
        case touchID
        case faceID
        case opticID

        var displayName: String {
            switch self {
            case .none:
                return "None"
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
            case .opticID:
                return "Optic ID"
            }
        }

        var icon: String {
            switch self {
            case .none:
                return "lock"
            case .touchID:
                return "touchid"
            case .faceID:
                return "faceid"
            case .opticID:
                return "opticid"
            }
        }
    }

    // MARK: - Availability Check

    /// Check if biometric authentication is available
    /// Note: Creates a fresh LAContext each time to avoid stale state
    func biometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .none:
            return .none
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .opticID
        @unknown default:
            return .none
        }
    }

    /// Check if any biometric is available
    var isBiometricAvailable: Bool {
        return biometricType() != .none
    }
    
    // MARK: - Authentication
    
    /// Authenticate user with biometrics
    func authenticate(reason: String = "Authenticate to access your medical records") -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(BiometricError.serviceUnavailable)
                return Disposables.create()
            }
            
            let context = LAContext()
            var error: NSError?
            
            // Check if biometric authentication is available
            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                if let error = error {
                    observer.onError(BiometricError.notAvailable(error))
                } else {
                    observer.onError(BiometricError.notAvailable(nil))
                }
                return Disposables.create()
            }
            
            // Perform authentication
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            ) { success, error in
                DispatchQueue.main.async {
                    if success {
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        if let error = error as? LAError {
                            observer.onError(BiometricError.authenticationFailed(error))
                        } else {
                            observer.onError(BiometricError.unknown)
                        }
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    /// Authenticate with fallback to passcode
    func authenticateWithPasscode(reason: String = "Authenticate to access your medical records") -> Observable<Bool> {
        return Observable.create { observer in
            let context = LAContext()
            var error: NSError?
            
            // Check if authentication is available (biometric or passcode)
            guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
                if let error = error {
                    observer.onError(BiometricError.notAvailable(error))
                } else {
                    observer.onError(BiometricError.notAvailable(nil))
                }
                return Disposables.create()
            }
            
            // Perform authentication (will fallback to passcode if biometric fails)
            context.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: reason
            ) { success, error in
                DispatchQueue.main.async {
                    if success {
                        observer.onNext(true)
                        observer.onCompleted()
                    } else {
                        if let error = error as? LAError {
                            observer.onError(BiometricError.authenticationFailed(error))
                        } else {
                            observer.onError(BiometricError.unknown)
                        }
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Errors
enum BiometricError: Error {
    case serviceUnavailable
    case notAvailable(NSError?)
    case authenticationFailed(LAError)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .serviceUnavailable:
            return "Biometric service is unavailable"
        case .notAvailable(let error):
            if let error = error {
                return "Biometric authentication not available: \(error.localizedDescription)"
            }
            return "Biometric authentication not available on this device"
        case .authenticationFailed(let error):
            return handleLAError(error)
        case .unknown:
            return "Unknown authentication error"
        }
    }
    
    private func handleLAError(_ error: LAError) -> String {
        switch error.code {
        case .authenticationFailed:
            return "Authentication failed. Please try again."
        case .userCancel:
            return "Authentication cancelled by user"
        case .userFallback:
            return "User chose to enter password"
        case .systemCancel:
            return "Authentication cancelled by system"
        case .passcodeNotSet:
            return "Passcode not set on device"
        case .biometryNotAvailable:
            return "Biometric authentication not available"
        case .biometryNotEnrolled:
            return "No biometric data enrolled"
        case .biometryLockout:
            return "Too many failed attempts. Please try again later."
        default:
            return "Authentication failed: \(error.localizedDescription)"
        }
    }
}

