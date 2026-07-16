//  ContentView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ===============================================================
//  Description: Root view handling onboarding, auth, and app state
//  ===============================================================

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    
    /// UserDefaults key to track if onboarding has been shown (persists across app launches)
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    /// Shared authentication view model - manages login/register state
    @StateObject private var authViewModel = AuthViewModel()
    
    /// Shared meal data view model - manages recipes, favorites, cookbook
    @StateObject private var mealViewModel = MealViewModel()
    
    /// Loading state while checking authentication status
    @State private var isLoading = true
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if isLoading {
                // Show loading screen while checking auth state
                ProgressView("Loading Nourishly...")
            } else if !hasSeenOnboarding {
                // Show onboarding for first-time users
                OnboardingView()
            } else if authViewModel.isAuthenticated {
                // User is logged in - show main app with shared ViewModels
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(mealViewModel)
            } else {
                // User is not logged in - show authentication choice screen
                // Pass ViewModels to child views via environment
                AuthChoiceView()
                    .environmentObject(authViewModel)
                    .environmentObject(mealViewModel)
            }
        }
        .task {
            // Small delay for smooth transition
            try? await Task.sleep(nanoseconds: 500_000_000)
            isLoading = false
        }
        .onChange(of: authViewModel.isAuthenticated) { _, isAuthenticated in
            // When user logs in, refresh data from Firestore
            if isAuthenticated, !authViewModel.userId.isEmpty {
                print("✅ User logged in - refreshing data")
                Task {
                    await mealViewModel.loadFavoritesFromFirestore(userId: authViewModel.userId)
                    _ = await mealViewModel.loadCookbookFromFirestore(userId: authViewModel.userId)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
