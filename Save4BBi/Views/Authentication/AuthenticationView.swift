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
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var pulseAnimation = false
    
    private let biometricService = BiometricService.shared
    private let disposeBag = DisposeBag()
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            VStack(spacing: 0) {
                Spacer()
                
                // App branding section
                VStack(spacing: 24) {
                    // Animated app icon
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.0)
                                    ],
                                    center: .center,
                                    startRadius: 60,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .opacity(pulseAnimation ? 0.5 : 0.8)
                        
                        // Icon background
                        Circle()
                            .fill(Color.white)
                            .frame(width: 120, height: 120)
                            .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                        
                        // Icon
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 56, weight: .medium))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.4, blue: 0.6),
                                        Color(red: 1.0, green: 0.6, blue: 0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .scaleEffect(scale)
                    .opacity(opacity)
                    
                    // App name and tagline
                    VStack(spacing: 8) {
                        Text("Save4BBi")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        Text("Your Baby's Health Journey")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white.opacity(0.95))
                            .tracking(0.5)
                    }
                    .opacity(opacity)
                }
                
                Spacer()
                Spacer()
                
                // Authentication section
                VStack(spacing: 28) {
                    // Security message
                    VStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Secure Access")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Protect your baby's medical records with biometric authentication")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.white.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .opacity(opacity)
                    
                    // Unlock button
                    Button {
                        authenticate()
                    } label: {
                        HStack(spacing: 14) {
                            if isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 1.0, green: 0.5, blue: 0.5)))
                                    .scaleEffect(1.3)
                            } else {
                                Image(systemName: biometricService.biometricType().icon)
                                    .font(.system(size: 22, weight: .semibold))
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Unlock App")
                                        .font(.system(size: 18, weight: .bold))
                                    Text("Use \\(biometricService.biometricType().displayName)")
                                        .font(.system(size: 13, weight: .medium))
                                        .opacity(0.8)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 66)
                        .background(
                            RoundedRectangle(cornerRadius: 33)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                        )
                        .foregroundColor(Color(red: 1.0, green: 0.5, blue: 0.5))
                    }
                    .disabled(isAuthenticating)
                    .scaleEffect(isAuthenticating ? 0.95 : 1.0)
                    .opacity(opacity)
                    
                    // Error message
                    if let errorMessage = errorMessage {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 16))
                            Text(errorMessage)
                                .font(.system(size: 15, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.25))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 70)
            }
        }
        .onAppear {
            // Entrance animations
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Pulse animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
            
            // Auto-trigger authentication
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                authenticate()
            }
        }
    }
    
    private func authenticate() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isAuthenticating = true
            errorMessage = nil
        }
        
        biometricService.authenticateWithPasscode(reason: "Unlock Save4BBi to access your baby's medical records")
            .observe(on: MainScheduler.instance)
            .subscribe(
                onNext: { success in
                    if success {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isAuthenticated = true
                        }
                    }
                    isAuthenticating = false
                },
                onError: { error in
                    isAuthenticating = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        if let biometricError = error as? BiometricError {
                            errorMessage = biometricError.localizedDescription
                        } else {
                            errorMessage = "Authentication failed. Please try again."
                        }
                    }
                    
                    // Clear error after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            errorMessage = nil
                        }
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.5, blue: 0.6),
                Color(red: 1.0, green: 0.6, blue: 0.5),
                Color(red: 1.0, green: 0.7, blue: 0.6),
                Color(red: 1.0, green: 0.8, blue: 0.7)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
        .overlay(
            // Decorative elements
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 350, height: 350)
                    .offset(x: -120, y: -350)
                    .blur(radius: 50)
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 280, height: 280)
                    .offset(x: 150, y: 450)
                    .blur(radius: 60)
                
                Circle()
                    .fill(Color.white.opacity(0.06))
                    .frame(width: 200, height: 200)
                    .offset(x: -180, y: 500)
                    .blur(radius: 40)
            }
        )
    }
}

// #Preview {
//     AuthenticationView(isAuthenticated: .constant(false))
// }
