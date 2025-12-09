//
//  View+DismissKeyboard.swift
//  MediFamily
//
//  Created by Cường Trần on 28/11/25.
//

import SwiftUI

extension View {
    /// Adds a tap gesture to dismiss keyboard when tapping outside of text fields
    /// Uses simultaneousGesture to avoid blocking other interactive elements like DatePicker
    func dismissKeyboardOnTap() -> some View {
        self.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
    }
    
    /// Wraps the view in a ScrollView with keyboard dismiss on drag
    func scrollDismissesKeyboard() -> some View {
        if #available(iOS 16.0, *) {
            return AnyView(self.scrollDismissesKeyboard(.interactively))
        } else {
            return AnyView(self)
        }
    }
}

// Helper to hide keyboard programmatically
extension UIApplication {
    func hideKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
