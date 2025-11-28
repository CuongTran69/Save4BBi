//
//  AuthenticationView.swift
//  Save4BBi
//
//  Created by Cường Trần on 27/11/25.
//

import SwiftUI
import RxSwift

struct AuthenticationView: View {
    @Binding var isAuthenticated: Bool
    
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    private let biometricService = BiometricService.shared
    private let disposeBag = DisposeBag()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Theme.Colors.primary.opacity(0.3), Theme.Colors.accent.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xl) {
                Spacer()
                
                // App icon/logo
                Image(systemName: biometricService.biometricType().icon)
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.primary)
                    .padding(Theme.Spacing.xl)
                    .background(Theme.Colors.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: Theme.Colors.shadow, radius: 16, x: 0, y: 8)
                
                // Title
                VStack(spacing: Theme.Spacing.sm) {
                    Text("Save4BBi")
                        .font(Theme.Typography.largeTitle)
                        .foregroundColor(Theme.Colors.text)
                    
                    Text("Medical Records for Your Little One")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Authentication button
                VStack(spacing: Theme.Spacing.md) {
                    Button {
                        authenticate()
                    } label: {
                        HStack {
                            if isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: biometricService.biometricType().icon)
                                Text("Unlock with \(biometricService.biometricType().displayName)")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.md)
                        .background(Theme.Colors.primary)
                        .foregroundColor(.white)
                        .font(Theme.Typography.bodyBold)
                        .cornerRadius(Theme.CornerRadius.medium)
                    }
                    .disabled(isAuthenticating)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(Theme.Typography.footnote)
                            .foregroundColor(Theme.Colors.error)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxl)
            }
        }
        .onAppear {
            // Auto-trigger authentication on appear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                authenticate()
            }
        }
    }
    
    private func authenticate() {
        isAuthenticating = true
        errorMessage = nil
        
        biometricService.authenticateWithPasscode(reason: "Authenticate to access your child's medical records")
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { success in
                    isAuthenticating = false
                    if success {
                        withAnimation {
                            isAuthenticated = true
                        }
                    }
                },
                onError: { error in
                    isAuthenticating = false
                    if let biometricError = error as? BiometricError {
                        errorMessage = biometricError.localizedDescription
                    } else {
                        errorMessage = "Authentication failed. Please try again."
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}

#Preview {
    AuthenticationView(isAuthenticated: .constant(false))
}
