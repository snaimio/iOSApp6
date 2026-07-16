//  AuthService.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ============================================================
//  Description: Handles all Firebase authentication operations
//  ============================================================

import Foundation
import FirebaseAuth
import Combine

// MARK: - Custom Authentication Errors

/// Custom authentication errors with user-friendly descriptions
enum AuthError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case passwordMismatch
    case weakPassword
    case userNotFound
    case networkError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .invalidPassword:
            return "Password must be at least 6 characters"
        case .passwordMismatch:
            return "Passwords do not match"
        case .weakPassword:
            return "Password is too weak. Please use a stronger password"
        case .userNotFound:
            return "No account found with this email"
        case .networkError:
            return "Network connection error. Please try again"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - Authentication Service

/// Service for handling all Firebase authentication operations
class AuthService: ObservableObject {
    // MARK: - Published Properties
    
    /// Currently authenticated user
    @Published var currentUser: AppUser?
    
    /// Whether the user is authenticated
    @Published var isAuthenticated = false
    
    /// Last authentication error message
    @Published var authError: String?
    
    /// Current user's Firebase UID
    @Published var userId: String?
    
    // MARK: - Private Properties
    
    private let auth = FirebaseManager.shared.auth
    
    // MARK: - Initialization
    
    init() {
        // Check if user is already signed in
        self.currentUser = auth.currentUser.map { AppUser(from: $0) }
        self.isAuthenticated = auth.currentUser != nil
        self.userId = auth.currentUser?.uid
        print("📝 AuthService initialized - isAuthenticated: \(isAuthenticated)")
    }
    
    // MARK: - Registration
    
    /// Register a new user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password (min 6 characters)
    ///   - confirmPassword: Password confirmation
    /// - Throws: AuthError if validation fails or Firebase returns an error
    func register(email: String, password: String, confirmPassword: String) async throws {
        // Validate inputs
        guard !email.isEmpty else { throw AuthError.invalidEmail }
        guard password.count >= 6 else { throw AuthError.invalidPassword }
        guard password == confirmPassword else { throw AuthError.passwordMismatch }
        
        print("📝 Registering user: \(email)")
        
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            await MainActor.run {
                self.currentUser = AppUser(from: result.user)
                self.isAuthenticated = true
                self.userId = result.user.uid
                self.authError = nil
                print("✅ Registration successful: \(email)")
            }
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
                print("❌ Registration error: \(error.localizedDescription)")
            }
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Login
    
    /// Login existing user with email and password
    /// - Parameters:
    ///   - email: User's email address
    ///   - password: User's password
    /// - Throws: AuthError if validation fails or Firebase returns an error
    func login(email: String, password: String) async throws {
        guard !email.isEmpty else { throw AuthError.invalidEmail }
        guard !password.isEmpty else { throw AuthError.invalidPassword }
        
        print("📝 Logging in user: \(email)")
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            await MainActor.run {
                self.currentUser = AppUser(from: result.user)
                self.isAuthenticated = true
                self.userId = result.user.uid
                self.authError = nil
                print("✅ Login successful: \(email)")
            }
        } catch {
            await MainActor.run {
                self.authError = error.localizedDescription
                print("❌ Login error: \(error.localizedDescription)")
            }
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - Logout
    
    /// Sign out the current user
    func logout() {
        print("📝 Logging out user")
        
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isAuthenticated = false
                self.userId = nil
                self.authError = nil
                print("✅ Logout successful")
            }
        } catch {
            DispatchQueue.main.async {
                self.authError = error.localizedDescription
                print("❌ Logout error: \(error.localizedDescription)")
            }
        }
    }
}
