//  FavoritesView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =====================================
//  Description: User's favorite recipes
//  =====================================

import SwiftUI

struct FavoritesView: View {
    // MARK: - Properties
    
    /// Shared meal data view model from parent
    @EnvironmentObject var mealViewModel: MealViewModel
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// List of favorite meals with full details
    @State private var favoriteMeals: [Meal] = []
    
    /// Loading state while fetching favorites
    @State private var isLoading = true
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    // Loading state
                    ProgressView("Loading favorites...")
                        .padding(.top, 40)
                } else if !authViewModel.isAuthenticated {
                    // Guest user - show sign in prompt
                    guestView
                } else if mealViewModel.favoriteMealIDs.isEmpty {
                    // Authenticated but no favorites yet
                    emptyStateView
                } else if favoriteMeals.isEmpty && !mealViewModel.favoriteMealIDs.isEmpty {
                    // Favorites exist but still loading details
                    ProgressView("Loading your favorites...")
                        .padding(.top, 40)
                } else {
                    // Show favorite recipes list
                    favoritesListView
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadFavorites()
            }
        }
    }
    
    // MARK: - Subviews
    
    /// View shown when user is not authenticated
    private var guestView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Sign in to save favorites")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Create an account or sign in to save your favorite recipes")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            NavigationLink {
                LoginView()
                    .environmentObject(authViewModel)
            } label: {
                Text("Sign In / Create Account")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    /// View shown when user has no favorites
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Start saving your favorite recipes")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink {
                DiscoverView()
                    .environmentObject(mealViewModel)
                    .environmentObject(authViewModel)
            } label: {
                Text("Discover Recipes")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
    
    /// List of favorite recipes
    private var favoritesListView: some View {
        List {
            ForEach(favoriteMeals) { meal in
                ZStack {
                    // Hidden NavigationLink for row tap navigation
                    NavigationLink {
                        FoodDetailView(meal: meal)
                            .environmentObject(mealViewModel)
                            .environmentObject(authViewModel)
                    } label: {
                        EmptyView()
                    }
                    .opacity(0) // Hidden but still functional
                    
                    // Custom Row Content - visible UI
                    HStack(spacing: 12) {
                        // Meal Thumbnail
                        if let url = URL(string: meal.strMealThumb ?? "") {
                            AsyncImage(url: url) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                        .clipped()
                                } else {
                                    // Placeholder while loading
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                        .cornerRadius(8)
                                        .overlay {
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        }
                                }
                            }
                        }
                        
                        // Meal Name and Category
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meal.strMeal)
                                .font(.headline)
                                .lineLimit(2)
                            
                            if let category = meal.strCategory {
                                Text(category)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        // Remove from Favorites Button
                        Button {
                            withAnimation {
                                // Toggle favorite status in ViewModel
                                mealViewModel.toggleFavorite(
                                    mealID: meal.idMeal,
                                    userId: authViewModel.userId,
                                    isAuthenticated: authViewModel.isAuthenticated
                                )
                                // Remove from local list immediately
                                favoriteMeals.removeAll { $0.idMeal == meal.idMeal }
                            }
                        } label: {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete { indexSet in
                // Swipe to delete functionality
                for index in indexSet {
                    let meal = favoriteMeals[index]
                    mealViewModel.toggleFavorite(
                        mealID: meal.idMeal,
                        userId: authViewModel.userId,
                        isAuthenticated: authViewModel.isAuthenticated
                    )
                    favoriteMeals.remove(at: index)
                }
            }
        }
        .refreshable {
            // Pull to refresh
            loadFavorites()
        }
    }
    
    // MARK: - Helper Functions
    
    /// Load favorite meals from the API
    func loadFavorites() {
        isLoading = true
        
        // Get favorite meal IDs from ViewModel
        let favoriteIDs = Array(mealViewModel.favoriteMealIDs)
        
        if favoriteIDs.isEmpty {
            // No favorites to load
            isLoading = false
            favoriteMeals = []
            return
        }
        
        // Fetch full meal details for each favorite ID
        Task {
            var meals: [Meal] = []
            
            for id in favoriteIDs {
                do {
                    let meal = try await MealService.shared.fetchMealDetail(id: id)
                    meals.append(meal)
                } catch {
                    print("❌ Error loading favorite meal \(id): \(error)")
                    // Continue loading other favorites even if one fails
                }
            }
            
            // Update UI on main thread
            await MainActor.run {
                favoriteMeals = meals
                isLoading = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    FavoritesView()
        .environmentObject(MealViewModel())
        .environmentObject(AuthViewModel())
}
