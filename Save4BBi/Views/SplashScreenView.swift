//
//  SplashScreenView.swift
//  Save4BBi
//
//  Created by Cường Trần on 28/11/25.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var showHome: Bool
    
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var rotationAngle: Double = 0
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.5, blue: 0.6),
                    Color(red: 1.0, green: 0.6, blue: 0.5),
                    Color(red: 1.0, green: 0.7, blue: 0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -120, y: -300)
                .blur(radius: 50)
            
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 250, height: 250)
                .offset(x: 150, y: 400)
                .blur(radius: 60)
            
            VStack(spacing: 24) {
                // App icon with animation
                ZStack {
                    // Rotating background circle
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Icon background
                    Circle()
                        .fill(Color.white)
                        .frame(width: 130, height: 130)
                        .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: 15)
                    
                    // Icon
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 60, weight: .medium))
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
                
                // App name
                VStack(spacing: 8) {
                    Text("Save4BBi")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    Text("Your Baby's Health Journey")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                        .tracking(0.5)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            // Entrance animation
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Rotation animation
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotationAngle = 360
            }
            
            // Navigate to home after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showHome = true
                }
            }
        }
    }
}

// #Preview {
//     SplashScreenView(showHome: .constant(false))
// }
