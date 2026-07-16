//  FirebaseManager.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =======================================================================
//  Description: Centralized Firebase configuration and instance management
//  =======================================================================

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore

// MARK: - Firebase Manager

/// Centralized Firebase configuration class providing shared instances
/// of Firebase services for the entire app
class FirebaseManager {
    // MARK: - Singleton
    
    /// Shared instance of FirebaseManager
    static let shared = FirebaseManager()
    
    // MARK: - Properties
    
    /// Firebase Authentication instance
    let auth: Auth
    
    /// Cloud Firestore instance
    let firestore: Firestore
    
    // MARK: - Initialization
    
    /// Private initializer to enforce singleton pattern
    private init() {
        // Firebase is configured in NourishlyApp.swift
        // These instances are ready to use after FirebaseApp.configure() is called
        self.auth = Auth.auth()
        self.firestore = Firestore.firestore()
        
        print("🔥 FirebaseManager initialized")
    }
}
