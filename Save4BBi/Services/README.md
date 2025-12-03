# Services Layer

This directory contains all service classes that handle business logic, data processing, and external integrations.

## 📦 Available Services

### 1. KeychainService
**Purpose**: Secure storage of encryption keys and sensitive data

**Key Features**:
- ✅ AES-256 encryption key generation and storage
- ✅ Secure keychain access with `.whenUnlockedThisDeviceOnly` accessibility
- ✅ RxSwift Observable-based API
- ✅ Generic string storage/retrieval

**Usage**:
```swift
// Get or create encryption key
Services.keychain.getOrCreateEncryptionKey()
    .subscribe(onNext: { key in
        print("Encryption key: \(key)")
    })
    .disposed(by: disposeBag)
```

**Dependencies**:
- KeychainAccess (~> 4.2)
- RxSwift (6.0)

---

### 2. EncryptionService
**Purpose**: Encrypt and decrypt photos and sensitive metadata

**Key Features**:
- ✅ AES-256-GCM authenticated encryption (Apple CryptoKit)
- ✅ Photo data encryption/decryption
- ✅ String encryption/decryption (for metadata)
- ✅ SHA-256 hashing for data integrity verification
- ✅ Automatic key management via KeychainService

**Usage**:
```swift
// Encrypt photo
Services.encryption.encryptPhoto(photoData)
    .subscribe(onNext: { encryptedData in
        // Save encrypted data
    })
    .disposed(by: disposeBag)

// Decrypt photo
Services.encryption.decryptPhoto(encryptedData)
    .subscribe(onNext: { decryptedData in
        let image = UIImage(data: decryptedData)
    })
    .disposed(by: disposeBag)
```

**Dependencies**:
- CryptoKit (iOS 13+, built-in)
- RxSwift (6.0)

---

### 3. PhotoService
**Purpose**: Photo capture, compression, encryption, and storage

**Key Features**:
- ✅ Image resizing (max 1920x1920)
- ✅ Smart compression (target 1MB)
- ✅ Automatic encryption before storage
- ✅ Encrypted file storage in app sandbox
- ✅ Photo loading with decryption
- ✅ Secure photo deletion

**Usage**:
```swift
// Save photo (resize + compress + encrypt)
Services.photo.savePhoto(image)
    .subscribe(onNext: { filename in
        print("Photo saved: \(filename)")
    })
    .disposed(by: disposeBag)

// Load photo (decrypt + display)
Services.photo.loadPhoto(filename: "uuid.enc")
    .subscribe(onNext: { image in
        imageView.image = image
    })
    .disposed(by: disposeBag)

// Delete photo
Services.photo.deletePhoto(filename: "uuid.enc")
    .subscribe()
    .disposed(by: disposeBag)
```

**Storage Location**:
- `Documents/EncryptedPhotos/` directory
- Files are encrypted with `.enc` extension

**Dependencies**:
- Kingfisher (~> 7.0)
- RxSwift (6.0)

---

## 🔐 Security Architecture

```
User Photo → PhotoService → EncryptionService → KeychainService
                ↓                    ↓                  ↓
            Resize/Compress    AES-256-GCM Encrypt  Encryption Key
                ↓                    ↓                  ↓
         Encrypted File      Secure Storage      iOS Keychain
```

### Security Features:
1. **AES-256-GCM Encryption**: Military-grade authenticated encryption (Apple CryptoKit)
2. **Random Nonce**: Each photo encrypted with unique nonce
3. **Authentication Tag**: Built-in data integrity verification
4. **Keychain Storage**: Encryption keys stored in iOS Keychain
5. **Local-Only**: All data stays on device, never sent to servers

---

## 📚 Dependencies Summary

| Library | Version | Purpose |
|---------|---------|---------|
| RxSwift | 6.0 | Reactive programming |
| RxCocoa | 6.0 | Cocoa-specific reactive extensions |
| KeychainAccess | ~> 4.2 | Simplified keychain wrapper |
| CryptoKit | Built-in (iOS 13+) | Apple's encryption framework |
| Kingfisher | ~> 7.0 | Image processing |

---

## ⚠️ Important Notes

1. **Encryption Key**: Never delete the encryption key unless you want to lose all encrypted data
2. **File Paths**: Always use relative filenames, not full paths
3. **Dispose Bags**: Always dispose of subscriptions to prevent memory leaks
4. **Error Handling**: All services provide detailed error types for proper error handling
5. **Thread Safety**: All services are thread-safe and handle background operations automatically

