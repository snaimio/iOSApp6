//  LoginView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ====================================================
//  Description: User login screen with forgot password
//  ====================================================

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    // MARK: - Properties
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// State for navigation to register screen
    @State private var showRegister = false
    
    /// State for forgot password sheet
    @State private var showForgotPassword = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // MARK: - App Logo
                VStack(spacing: 10) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Nourishly")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Eat well. Live well.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                
                // MARK: - Login Form
                VStack(spacing: 20) {
                    // Email field
                    TextField("Email", text: $authViewModel.email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                    
                    // Password field
                    SecureField("Password", text: $authViewModel.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Forgot Password Button
                    HStack {
                        Spacer()
                        Button {
                            showForgotPassword = true
                        } label: {
                            Text("Forgot Password?")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Login Button
                    Button {
                        authViewModel.login()
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Login")
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
                
                // MARK: - Register Navigation
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    
                    Button {
                        showRegister = true
                    } label: {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authViewModel)
            }
            .alert("Login Error", isPresented: $authViewModel.showAlert) {
                Button("OK") {
                    authViewModel.errorMessage = ""
                }
            } message: {
                Text(authViewModel.errorMessage)
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    // MARK: - Properties
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var message = ""
    @State private var showAlert = false
    @State private var isSuccess = false
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "envelope")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Reset Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Enter your email and we'll send you a link to reset your password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                // Email Field
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                    
                    Button {
                        Task {
                            await sendPasswordReset()
                        }
                    } label: {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(email.isEmpty || isLoading)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert(isSuccess ? "Success" : "Error", isPresented: $showAlert) {
                Button("OK") {
                    if isSuccess {
                        dismiss()
                    }
                }
            } message: {
                Text(message)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Send password reset email using Firebase Authentication
    func sendPasswordReset() async {
        isLoading = true
        message = ""
        
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            isSuccess = true
            message = "Password reset link sent to \(email). Please check your email."
            isLoading = false
            showAlert = true
        } catch {
            isSuccess = false
            message = error.localizedDescription
            isLoading = false
            showAlert = true
        }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
