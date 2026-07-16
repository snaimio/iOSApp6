//  AppUser.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ========================================================================
//  Description: User model representing an authenticated user from Firebase
//  ========================================================================

import Foundation
import FirebaseAuth

// MARK: - App User Model

/// User model representing an authenticated user from Firebase Authentication
struct AppUser: Identifiable {
    // MARK: - Properties
    
    /// Firebase User ID (UID)
    let id: String
    
    /// User's email address
    let email: String
    
    /// User's display name (optional)
    let displayName: String?
    
    // MARK: - Initialization
    
    /// Initialize from a Firebase User object
    /// - Parameter firebaseUser: The Firebase User object from FirebaseAuth
    init(from firebaseUser: User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.displayName = firebaseUser.displayName
    }
}
