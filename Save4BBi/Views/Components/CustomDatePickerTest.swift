//
//  CustomDatePickerTest.swift
//  MediFamily
//
//  Created by Cường Trần on 09/12/25.
//

import SwiftUI

/// Simple test view to debug CustomDatePicker
struct CustomDatePickerTest: View {
    @State private var selectedDate = Date()
    @State private var showDebug = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Test 1: Simple Date Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test 1: Simple Date Picker")
                            .font(.headline)
                        
                        CustomDatePicker(
                            "Select Date",
                            selection: $selectedDate,
                            mode: .date
                        )
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Debug Info
                    if showDebug {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Debug Info")
                                .font(.headline)
                            
                            Text("Selected Date: \(selectedDate.formatted())")
                                .font(.caption)
                            
                            Text("Timestamp: \(selectedDate.timeIntervalSince1970)")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Test 2: Standard DatePicker for comparison
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test 2: Standard DatePicker (for comparison)")
                            .font(.headline)
                        
                        DatePicker(
                            "Standard Picker",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("DatePicker Test")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showDebug.toggle()
                    } label: {
                        Image(systemName: showDebug ? "eye.fill" : "eye.slash.fill")
                    }
                }
            }
        }
    }
}

