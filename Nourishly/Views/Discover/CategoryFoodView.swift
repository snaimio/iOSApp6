//  CategoryFoodView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ============================================================
//  Description: Food items by category with full recipe access
//  ============================================================

import SwiftUI

struct CategoryFoodView: View {
    // MARK: - Properties
    
    /// The selected category to display meals from
    let category: Category
    
    /// Shared meal data view model from parent
    @EnvironmentObject var mealViewModel: MealViewModel
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// Local search text for filtering meals within this category
    @State private var searchText = ""
    
    /// Filtered meals based on search text
    var filteredMeals: [Meal] {
        if searchText.isEmpty {
            return mealViewModel.meals
        } else {
            return mealViewModel.meals.filter {
                $0.strMeal.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if mealViewModel.isLoading {
                // Loading state
                ProgressView("Loading recipes...")
                    .padding(.top, 40)
            } else if let error = mealViewModel.errorMessage {
                // Error state with retry option
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await mealViewModel.loadMeals(for: category.strCategory)
                        }
                    }
                }
                .padding()
            } else if mealViewModel.meals.isEmpty {
                // Empty state - no meals found
                VStack(spacing: 20) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No recipes found in \(category.strCategory)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Try a different category")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                // List of meals in the category
                List(filteredMeals) { meal in
                    NavigationLink {
                        FoodDetailView(meal: meal)
                            .environmentObject(mealViewModel)
                            .environmentObject(authViewModel)
                    } label: {
                        HStack(spacing: 12) {
                            // Meal thumbnail
                            if let url = URL(string: meal.strMealThumb ?? "") {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                            .clipped()
                                    } else {
                                        // Placeholder while loading
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(8)
                                            .overlay {
                                                Image(systemName: "photo")
                                                    .foregroundColor(.gray)
                                            }
                                    }
                                }
                            }
                            
                            // Meal name and cuisine
                            VStack(alignment: .leading, spacing: 4) {
                                Text(meal.strMeal)
                                    .font(.headline)
                                    .lineLimit(2)
                                
                                if let area = meal.strArea {
                                    Text(area)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Favorite indicator
                            if mealViewModel.isFavorite(mealID: meal.idMeal) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .refreshable {
                    // Pull to refresh
                    await mealViewModel.loadMeals(for: category.strCategory)
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Search in \(category.strCategory)"
                )
            }
        }
        .navigationTitle(category.strCategory)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Only load if meals are empty or different category
            if mealViewModel.currentCategory != category.strCategory || mealViewModel.meals.isEmpty {
                await mealViewModel.loadMeals(for: category.strCategory)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CategoryFoodView(
            category: Category(
                idCategory: "1",
                strCategory: "Beef",
                strCategoryThumb: "https://www.themealdb.com/images/category/beef.png",
                strCategoryDescription: "Beef dishes"
            )
        )
        .environmentObject(MealViewModel())
        .environmentObject(AuthViewModel())
    }
}
