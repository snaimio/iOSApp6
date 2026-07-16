//  RegisterView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ======================================
//  Description: User registration screen
//  ======================================

import SwiftUI

struct RegisterView: View {
    // MARK: - Properties
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// Dismiss environment to go back to login screen
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 25) {
            // MARK: - Header
            VStack(spacing: 10) {
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Start your nourishing journey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // MARK: - Registration Form
            VStack(spacing: 20) {
                // Email field
                TextField("Email", text: $authViewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                
                // Password field
                SecureField("Password (min 6 characters)", text: $authViewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Confirm password field
                SecureField("Confirm Password", text: $authViewModel.confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Register Button
                Button {
                    authViewModel.register()
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(authViewModel.isLoading)
            }
            .padding(.horizontal, 30)
            
            // MARK: - Login Navigation
            Button("Already have an account? Login") {
                dismiss()
            }
            .foregroundColor(.green)
            
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .alert("Registration Error", isPresented: $authViewModel.showAlert) {
            Button("OK") {
                authViewModel.errorMessage = ""
            }
        } message: {
            Text(authViewModel.errorMessage)
        }
    }
}

// MARK: - Preview

#Preview {
    RegisterView()
        .environmentObject(AuthViewModel())
}
