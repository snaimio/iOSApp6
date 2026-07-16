//
//  ProfileView.swift
//  Nourishly
//
//  Created by Sheikh Naim on 2026-07-16.
//  Description: User profile and settings
//

import SwiftUI

struct ProfileView: View {
    // MARK: - Properties
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// State for showing login prompt sheet
    @State private var showLoginPrompt = false
    
    /// User stats - updated from UserDefaults
    @State private var recipesCooked: Int = 0
    @State private var favoritesCount: Int = 0
    @State private var daysActive: Int = 0
    
    /// Trigger for refreshing the view
    @State private var refreshTrigger = UUID()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // MARK: - User Avatar
                Image(systemName: authViewModel.isAuthenticated ? "person.circle.fill" : "person.crop.circle.badge.questionmark.fill")
                    .font(.system(size: 80))
                    .foregroundColor(authViewModel.isAuthenticated ? .green : .gray)
                
                // MARK: - User Info
                if authViewModel.isAuthenticated {
                    // Logged In User
                    if let user = authViewModel.currentUser {
                        Text(user.displayName ?? "User")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    // Guest User
                    Text("Guest User")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Sign in to save your progress")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button {
                        showLoginPrompt = true
                    } label: {
                        Text("Sign In / Create Account")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 30)
                }
                
                Divider()
                    .padding(.horizontal)
                
                // MARK: - Stats
                HStack(spacing: 30) {
                    // Recipes Cooked
                    VStack {
                        Text("\(recipesCooked)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Recipes Cooked")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Favorites
                    VStack {
                        Text("\(favoritesCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Favorites")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Days Active
                    VStack {
                        Text("\(daysActive)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("Days Active")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // MARK: - Settings
                List {
                    if authViewModel.isAuthenticated {
                        Section("Account") {
                            Button(role: .destructive) {
                                authViewModel.logout()
                            } label: {
                                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                            }
                        }
                    } else {
                        Section("Account") {
                            Button {
                                showLoginPrompt = true
                            } label: {
                                Label("Sign In / Create Account", systemImage: "person.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    
                    Section("About") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Status")
                            Spacer()
                            Text(authViewModel.isAuthenticated ? "Signed In" : "Guest")
                                .foregroundColor(authViewModel.isAuthenticated ? .green : .secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                updateStats()
                setupNotificationObserver()
            }
            .onDisappear {
                removeNotificationObserver()
            }
            .id(refreshTrigger)
            .sheet(isPresented: $showLoginPrompt) {
                AuthChoiceView()
                    .environmentObject(authViewModel)
            }
        }
    }
    
    // MARK: - Notification System
    
    /// Listen for cookbook updates to refresh stats
    func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CookbookUpdated"),
            object: nil,
            queue: .main
        ) { _ in
            print("📢 Profile received cookbook update")
            updateStats()
            refreshTrigger = UUID()
        }
    }
    
    /// Remove notification observer
    func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Stats Helper Functions
    
    /// Update all stats from UserDefaults
    func updateStats() {
        updateRecipesCooked()
        updateFavoritesCount()
        calculateDaysActive()
    }
    
    /// Load recipes cooked count from UserDefaults
    func updateRecipesCooked() {
        if let data = UserDefaults.standard.data(forKey: "cookbook"),
           let meals = try? JSONDecoder().decode([CookedMeal].self, from: data) {
            recipesCooked = meals.count
            print("📚 Recipes Cooked: \(recipesCooked)")
        } else {
            recipesCooked = 0
        }
    }
    
    /// Load favorites count from UserDefaults
    func updateFavoritesCount() {
        if let data = UserDefaults.standard.data(forKey: "favoriteMealIDs"),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoritesCount = ids.count
            print("❤️ Favorites: \(favoritesCount)")
        } else {
            favoritesCount = 0
        }
    }
    
    /// Calculate days active based on first cooked meal date
    func calculateDaysActive() {
        if let data = UserDefaults.standard.data(forKey: "cookbook"),
           let meals = try? JSONDecoder().decode([CookedMeal].self, from: data),
           let firstMeal = meals.sorted(by: { $0.dateCooked < $1.dateCooked }).first {
            
            let calendar = Calendar.current
            let days = calendar.dateComponents([.day], from: firstMeal.dateCooked, to: Date()).day ?? 0
            daysActive = days + 1 // Include today
            print("📅 Days Active: \(daysActive)")
        } else {
            daysActive = 0
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
