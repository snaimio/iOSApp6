//  LoadingView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =================================================
//  Description: Reusable loading indicator component
//  =================================================

import SwiftUI

struct LoadingView: View {
    // MARK: - Properties
    
    /// The loading message to display
    let message: String
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Spinner with increased scale
            ProgressView()
                .scaleEffect(1.5)
            
            // Loading message
            Text(message)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    LoadingView(message: "Loading...")
}
