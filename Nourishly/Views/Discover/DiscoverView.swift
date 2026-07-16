//  DiscoverView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ============================================================
//  Description: Discover screen with category cards and search
//  ============================================================

import SwiftUI

struct DiscoverView: View {
    // MARK: - Properties
    
    /// Shared meal data view model from parent
    @EnvironmentObject var mealViewModel: MealViewModel
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// State for showing random meal navigation
    @State private var showingRandomMeal = false
    @State private var isSearching = false
    
    /// Grid layout for category cards - 2 columns with 16pt spacing
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    /// Priority categories that should appear first
    private let priorityCategories = ["Breakfast", "Lunch", "Dinner"]
    
    /// Sorted categories with priority items first
    var sortedCategories: [Category] {
        var sorted: [Category] = []
        var remaining: [Category] = []
        
        // First, add priority categories in order (Breakfast, Lunch, Dinner)
        for priority in priorityCategories {
            if let category = mealViewModel.categories.first(where: { $0.strCategory == priority }) {
                sorted.append(category)
            }
        }
        
        // Then add all other categories
        for category in mealViewModel.categories {
            if !priorityCategories.contains(category.strCategory) {
                remaining.append(category)
            }
        }
        
        // Sort remaining categories alphabetically
        remaining.sort { $0.strCategory < $1.strCategory }
        
        return sorted + remaining
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        TextField("Search recipes...", text: $mealViewModel.searchText)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .onSubmit {
                                isSearching = true
                                Task {
                                    await mealViewModel.searchMeals(query: mealViewModel.searchText)
                                }
                            }
                        
                        if !mealViewModel.searchText.isEmpty {
                            Button {
                                mealViewModel.searchText = ""
                                mealViewModel.meals = []
                                isSearching = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .padding(.horizontal, 16)
                    
                    // MARK: - Search Results or Regular Content
                    if isSearching || !mealViewModel.searchText.isEmpty {
                        // Show Search Results
                        if mealViewModel.isLoading {
                            ProgressView("Searching...")
                                .padding(.top, 40)
                        } else if mealViewModel.meals.isEmpty && !mealViewModel.searchText.isEmpty {
                            // No results
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray)
                                Text("No recipes found")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Try a different search term")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                        } else if !mealViewModel.meals.isEmpty {
                            // Show search results
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Search Results")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Text("\(mealViewModel.meals.count) recipes")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(mealViewModel.meals) { meal in
                                        NavigationLink {
                                            FoodDetailView(meal: meal)
                                                .environmentObject(mealViewModel)
                                                .environmentObject(authViewModel)
                                        } label: {
                                            MealCardView(
                                                meal: meal,
                                                isFavorite: mealViewModel.isFavorite(mealID: meal.idMeal),
                                                onFavoriteToggle: {
                                                    mealViewModel.toggleFavorite(
                                                        mealID: meal.idMeal,
                                                        userId: authViewModel.userId,
                                                        isAuthenticated: authViewModel.isAuthenticated
                                                    )
                                                }
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    } else {
                        // MARK: - Regular Content (Categories)
                        // Surprise Me Button
                        Button {
                            Task {
                                await mealViewModel.loadRandomMeal()
                                if mealViewModel.selectedMeal != nil {
                                    showingRandomMeal = true
                                }
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .medium))
                                    .symbolRenderingMode(.hierarchical)
                                
                                Text("Surprise Me!")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.2, green: 0.6, blue: 0.3),
                                        Color(red: 0.1, green: 0.5, blue: 0.2)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: Color.green.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 16)
                        
                        // Categories Section
                        if mealViewModel.isLoading {
                            ProgressView("Loading categories...")
                                .padding(.top, 40)
                        } else if let error = mealViewModel.errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                Text("Error: \(error)")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                Button("Retry") {
                                    Task {
                                        await mealViewModel.loadCategories()
                                    }
                                }
                            }
                            .padding(.top, 40)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                // Section Header
                                HStack {
                                    Text("Categories")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    
                                    Spacer()
                                    
                                    Text("\(mealViewModel.categories.count) categories")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                
                                // Category Cards Grid
                                LazyVGrid(columns: columns, spacing: 16) {
                                    ForEach(sortedCategories) { category in
                                        NavigationLink {
                                            CategoryFoodView(category: category)
                                                .environmentObject(mealViewModel)
                                                .environmentObject(authViewModel)
                                        } label: {
                                            CategoryCardView(category: category)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                    }
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Nourishly")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        FavoritesView()
                            .environmentObject(mealViewModel)
                            .environmentObject(authViewModel)
                    } label: {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                    }
                }
            }
            .task {
                // Load categories when view appears
                if mealViewModel.categories.isEmpty {
                    await mealViewModel.loadCategories()
                }
            }
            .navigationDestination(item: $mealViewModel.selectedMeal) { meal in
                // Navigate to random meal detail
                FoodDetailView(meal: meal)
                    .environmentObject(mealViewModel)
                    .environmentObject(authViewModel)
            }
            .onChange(of: mealViewModel.searchText) { _, newValue in
                if newValue.isEmpty {
                    isSearching = false
                    mealViewModel.meals = []
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DiscoverView()
        .environmentObject(MealViewModel())
        .environmentObject(AuthViewModel())
}
