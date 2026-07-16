//  MainTabView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ================================================
//  Description: Main tab bar navigation for the app
//  ================================================

import SwiftUI

struct MainTabView: View {
    // MARK: - Properties
    
    /// Shared meal data view model from parent
    @EnvironmentObject var mealViewModel: MealViewModel
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// Currently selected tab index (0 = Discover, 1 = Favorites, 2 = Cookbook, 3 = Profile)
    @State private var selectedTab = 0
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab 1: Discover
            /// Browse and search for recipes
            DiscoverView()
                .environmentObject(mealViewModel)
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Discover", systemImage: "house.fill")
                }
                .tag(0)
            
            // MARK: - Tab 2: Favorites
            /// View saved favorite recipes (requires authentication)
            FavoritesView()
                .environmentObject(mealViewModel)
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(1)
            
            // MARK: - Tab 3: Cookbook
            /// Track cooked recipes with ratings and notes
            CookbookView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Cookbook", systemImage: "book.fill")
                }
                .tag(2)
            
            // MARK: - Tab 4: Profile
            /// User information, settings, and stats
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.green) // Green accent color for selected tab icons
        .onAppear {
            // Reload data from Firestore when tab view appears (only if authenticated)
            if authViewModel.isAuthenticated && !authViewModel.userId.isEmpty {
                Task {
                    // Load favorites from Firestore
                    await mealViewModel.loadFavoritesFromFirestore(userId: authViewModel.userId)
                    // Load cookbook from Firestore
                    _ = await mealViewModel.loadCookbookFromFirestore(userId: authViewModel.userId)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(MealViewModel())
        .environmentObject(AuthViewModel())
}
