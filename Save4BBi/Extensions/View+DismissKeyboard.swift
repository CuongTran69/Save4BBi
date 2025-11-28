//
//  View+DismissKeyboard.swift
//  Save4BBi
//
//  Created by Cường Trần on 28/11/25.
//

import SwiftUI

extension View {
    /// Adds a tap gesture to dismiss keyboard when tapping outside of text fields
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
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
