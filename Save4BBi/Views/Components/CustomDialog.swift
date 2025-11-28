//
//  CustomDialog.swift
//  Save4BBi
//
//  Created by Cường Trần on 28/11/25.
//

import SwiftUI

struct CustomDialog<Content: View>: View {
    let title: String
    let message: String?
    let primaryButton: DialogButton
    let secondaryButton: DialogButton?
    let content: (() -> Content)?
    
    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    init(
        title: String,
        message: String? = nil,
        primaryButton: DialogButton,
        secondaryButton: DialogButton? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.content = content
    }
    
    init(
        title: String,
        message: String? = nil,
        primaryButton: DialogButton,
        secondaryButton: DialogButton? = nil
    ) where Content == EmptyView {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.content = nil
    }
    
    var body: some View {
        ZStack {
            // Backdrop
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Dialog
            VStack(spacing: 0) {
                // Title
                Text(title)
                    .font(Theme.Typography.title2)
                    .foregroundColor(Theme.Colors.text)
                    .padding(.top, Theme.Spacing.xl)
                    .padding(.horizontal, Theme.Spacing.xl)
                
                // Message
                if let message = message {
                    Text(message)
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.Colors.text.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.top, Theme.Spacing.md)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
                
                // Custom content
                if let content = content {
                    content()
                        .padding(.top, Theme.Spacing.md)
                        .padding(.horizontal, Theme.Spacing.xl)
                }
                
                // Buttons
                HStack(spacing: Theme.Spacing.md) {
                    if let secondaryButton = secondaryButton {
                        Button {
                            dismissWithAnimation()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                secondaryButton.action()
                            }
                        } label: {
                            Text(secondaryButton.title)
                                .font(Theme.Typography.bodyBold)
                                .foregroundColor(Theme.Colors.text.opacity(0.6))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.md)
                                .background(Theme.Colors.background)
                                .cornerRadius(Theme.CornerRadius.medium)
                        }
                    }
                    
                    Button {
                        dismissWithAnimation()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            primaryButton.action()
                        }
                    } label: {
                        Text(primaryButton.title)
                            .font(Theme.Typography.bodyBold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.md)
                            .background(primaryButton.isDestructive ? Theme.Colors.error : Theme.Colors.primary)
                            .cornerRadius(Theme.CornerRadius.medium)
                    }
                }
                .padding(Theme.Spacing.xl)
            }
            .frame(maxWidth: 320)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(color: Theme.Colors.shadow.opacity(0.3), radius: 20, x: 0, y: 10)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func dismissWithAnimation() {
        withAnimation(.easeInOut(duration: 0.2)) {
            scale = 0.8
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            dismiss()
        }
    }
}

// MARK: - Dialog Button
struct DialogButton {
    let title: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(title: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
    }
}

// MARK: - View Extension
extension View {
    func customDialog<Content: View>(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        primaryButton: DialogButton,
        secondaryButton: DialogButton? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.fullScreenCover(isPresented: isPresented) {
            CustomDialog(
                title: title,
                message: message,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton,
                content: content
            )
            .background(ClearBackgroundView())
        }
    }
    
    func customDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String? = nil,
        primaryButton: DialogButton,
        secondaryButton: DialogButton? = nil
    ) -> some View {
        self.fullScreenCover(isPresented: isPresented) {
            CustomDialog<EmptyView>(
                title: title,
                message: message,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
            .background(ClearBackgroundView())
        }
    }
}

// MARK: - Clear Background
struct ClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// #Preview {
//     VStack {
//         Text("Background Content")
//     }
//     .customDialog(
//         isPresented: .constant(true),
//         title: "Delete Visit?",
//         message: "This action cannot be undone.",
//         primaryButton: DialogButton(title: "Delete", isDestructive: true) {
//             print("Deleted")
//         },
//         secondaryButton: DialogButton(title: "Cancel") {
//             print("Cancelled")
//         }
//     )
// }
