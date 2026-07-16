//  ErrorView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ======================================================
//  Description: Reusable error display with retry option
//  ======================================================

import SwiftUI

struct ErrorView: View {
    // MARK: - Properties
    
    /// The error message to display
    let message: String
    
    /// Callback when the retry button is tapped
    let retryAction: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Error icon
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            // Error title
            Text("Oops! Something went wrong")
                .font(.headline)
            
            // Error message
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Retry button
            Button(action: retryAction) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 30)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    ErrorView(message: "Network connection error") {
        print("Retry tapped")
    }
}
