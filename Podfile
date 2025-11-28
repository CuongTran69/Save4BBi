platform :ios, '16.0'
use_frameworks!

target 'Save4BBi' do
  # Reactive Programming
  pod 'RxSwift', '6.0'
  pod 'RxCocoa', '6.0'
  pod 'RxRelay', '6.0'

  # Image Processing & Compression
  pod 'Kingfisher', '~> 7.0'  # Image caching and processing

  # Keychain Access
  pod 'KeychainAccess', '~> 4.2'  # Simplified keychain wrapper

  # UI Components
  pod 'SnapKit', '~> 5.0'  # Auto Layout DSL (if needed for UIKit components)

  # Utilities
  pod 'SwiftDate', '~> 7.0'  # Date manipulation utilities

  # Note: Using CryptoKit (built-in iOS 13+) instead of CryptoSwift to avoid build issues
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
end