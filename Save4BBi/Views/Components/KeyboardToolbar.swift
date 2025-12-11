import SwiftUI

// MARK: - Keyboard Toolbar Modifier
struct KeyboardToolbar: ViewModifier {
    let lang = LanguageManager.shared
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(lang.localized("button.done")) {
                        hideKeyboard()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primary)
                }
            }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Keyboard Toolbar with Navigation
struct KeyboardToolbarWithNavigation: ViewModifier {
    let lang = LanguageManager.shared
    @FocusState.Binding var focusedField: Int?
    let totalFields: Int
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    // Previous button
                    Button {
                        if let current = focusedField, current > 0 {
                            focusedField = current - 1
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(focusedField == nil || focusedField == 0)
                    .foregroundColor((focusedField == nil || focusedField == 0) ? Theme.Colors.text.opacity(0.3) : Theme.Colors.primary)
                    
                    // Next button
                    Button {
                        if let current = focusedField, current < totalFields - 1 {
                            focusedField = current + 1
                        }
                    } label: {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(focusedField == nil || focusedField == totalFields - 1)
                    .foregroundColor((focusedField == nil || focusedField == totalFields - 1) ? Theme.Colors.text.opacity(0.3) : Theme.Colors.primary)
                    
                    Spacer()
                    
                    // Done button
                    Button(lang.localized("button.done")) {
                        hideKeyboard()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.primary)
                }
            }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - View Extensions
extension View {
    /// Adds a keyboard toolbar with Done button
    func keyboardDoneButton() -> some View {
        modifier(KeyboardToolbar())
    }

    /// Adds a keyboard toolbar with Previous/Next/Done buttons
    func keyboardNavigationToolbar(focusedField: FocusState<Int?>.Binding, totalFields: Int) -> some View {
        modifier(KeyboardToolbarWithNavigation(focusedField: focusedField, totalFields: totalFields))
    }

    /// Hides keyboard programmatically
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

