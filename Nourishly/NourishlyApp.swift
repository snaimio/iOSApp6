//  NourishlyApp.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ==============================================================
//  Description: Main app entry point with Firebase configuration
//  ==============================================================

import SwiftUI
import FirebaseCore

@main
struct NourishlyApp: App {
    
    // MARK: - Initialization
    init() {
        // Configure Firebase when app launches - must be done before any Firebase services are used
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
