//  AuthViewModel.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ================================================
//  Description: ViewModel for authentication state
//  ================================================

import SwiftUI
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// User's email for login/registration
    @Published var email = ""
    
    /// User's password for login/registration
    @Published var password = ""
    
    /// Password confirmation for registration
    @Published var confirmPassword = ""
    
    /// Loading state during authentication
    @Published var isLoading = false
    
    /// Error message for authentication failures
    @Published var errorMessage = ""
    
    /// Whether to show the error alert
    @Published var showAlert = false
    
    /// Whether the user is authenticated
    @Published var isAuthenticated = false
    
    /// Firebase user ID
    @Published var userId = ""
    
    /// Current authenticated user
    @Published var currentUser: AppUser? = nil
    
    // MARK: - Private Properties
    
    private var auth = Auth.auth()
    
    // MARK: - Initialization
    
    init() {
        checkAuthState()
    }
    
    // MARK: - Public Methods
    
    /// Check if user is already signed in
    func checkAuthState() {
        if let user = auth.currentUser {
            isAuthenticated = true
            userId = user.uid
            currentUser = AppUser(from: user)
            print("✅ User already signed in: \(user.email ?? "unknown")")
        } else {
            isAuthenticated = false
            userId = ""
            currentUser = nil
            print("❌ No user signed in")
        }
    }
    
    /// Register a new user with email and password
    func register() {
        // Validate inputs
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            showAlert = true
            return
        }
        
        isLoading = true
        print("📝 Registering user: \(email)")
        
        Task {
            do {
                let result = try await auth.createUser(withEmail: email, password: password)
                await MainActor.run {
                    isAuthenticated = true
                    userId = result.user.uid
                    currentUser = AppUser(from: result.user)
                    isLoading = false
                    clearFields()
                    print("✅ Registration successful: \(email)")
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showAlert = true
                    isLoading = false
                    print("❌ Registration error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Login existing user with email and password
    func login() {
        // Validate inputs
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields"
            showAlert = true
            return
        }
        
        isLoading = true
        print("📝 Logging in user: \(email)")
        
        Task {
            do {
                let result = try await auth.signIn(withEmail: email, password: password)
                await MainActor.run {
                    isAuthenticated = true
                    userId = result.user.uid
                    currentUser = AppUser(from: result.user)
                    isLoading = false
                    clearFields()
                    print("✅ Login successful: \(email)")
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showAlert = true
                    isLoading = false
                    print("❌ Login error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Logout current user and clear local data
    func logout() {
        print("📝 Logging out user")
        
        do {
            try auth.signOut()
            isAuthenticated = false
            userId = ""
            currentUser = nil
            
            // Clear local UserDefaults data
            UserDefaults.standard.removeObject(forKey: "favoriteMealIDs")
            UserDefaults.standard.removeObject(forKey: "cookbook")
            
            print("✅ Logout successful - local data cleared")
        } catch {
            errorMessage = error.localizedDescription
            showAlert = true
            print("❌ Logout error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Helpers
    
    /// Clear all form fields
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
    }
}
