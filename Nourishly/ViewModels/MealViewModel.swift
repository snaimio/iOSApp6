//  MealViewModel.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =================================================================
//  Description: ViewModel for meal data with local + Firestore sync
//  =================================================================

import SwiftUI
import Combine

@MainActor
class MealViewModel: ObservableObject {
    // MARK: - Published Properties
    
    /// List of all categories from the API
    @Published var categories: [Category] = []
    
    /// List of meals for the current category
    @Published var meals: [Meal] = []
    
    /// Currently selected meal (for random meal or detail view)
    @Published var selectedMeal: Meal?
    
    /// Search text for filtering meals
    @Published var searchText = ""
    
    /// Loading state for API calls
    @Published var isLoading = false
    
    /// Error message for API failures
    @Published var errorMessage: String?
    
    /// Whether to show the error alert
    @Published var showError = false
    
    /// Set of favorite meal IDs (stored locally and synced to Firestore)
    @Published var favoriteMealIDs: Set<String> = []
    
    /// Whether to show the authentication required alert
    @Published var showAuthAlert = false
    
    /// Current category being viewed
    @Published var currentCategory = ""
    
    /// Whether data is syncing with Firestore
    @Published var isSyncing = false
    
    // MARK: - Constants
    
    private let favoritesKey = "favoriteMealIDs"
    private let mealService = MealService.shared
    private let firestore = FirestoreService.shared
    
    // MARK: - Computed Properties
    
    /// Filtered meals based on search text
    var filteredMeals: [Meal] {
        if searchText.isEmpty {
            return meals
        } else {
            return meals.filter { $0.strMeal.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    /// Meals that are favorited
    var favoriteMeals: [Meal] {
        meals.filter { favoriteMealIDs.contains($0.idMeal) }
    }
    
    // MARK: - Initialization
    
    init() {
        loadFavorites()
    }
    
    // MARK: - API Methods
    
    /// Load all categories from the API
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await mealService.fetchCategories()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    /// Load meals for a specific category
    func loadMeals(for category: String) async {
        isLoading = true
        errorMessage = nil
        meals = []
        currentCategory = category
        
        print("📂 Loading meals for category: \(category)")
        
        do {
            let fetchedMeals = try await mealService.fetchMealsByCategory(category)
            meals = fetchedMeals
            print("✅ Loaded \(meals.count) meals for category: \(category)")
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            print("❌ Error loading meals for category \(category): \(error)")
        }
    }
    
    /// Load full details for a specific meal
    func loadMealDetail(id: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            selectedMeal = try await mealService.fetchMealDetail(id: id)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    /// Search meals by name
    func searchMeals(query: String) async {
        guard !query.isEmpty else {
            meals = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            meals = try await mealService.searchMeals(query: query)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    /// Load a random meal
    func loadRandomMeal() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let meal = try await mealService.fetchRandomMeal()
            selectedMeal = meal
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
        }
    }
    
    // MARK: - Favorites Management (with Firestore Sync)
    
    /// Toggle favorite status - saves to local + Firestore if authenticated
    func toggleFavorite(mealID: String, userId: String?, isAuthenticated: Bool) {
        // Check if user is authenticated
        guard isAuthenticated else {
            showAuthAlert = true
            return
        }
        
        // Toggle locally
        if favoriteMealIDs.contains(mealID) {
            favoriteMealIDs.remove(mealID)
        } else {
            favoriteMealIDs.insert(mealID)
        }
        saveFavorites()
        
        // Sync to Firestore if authenticated
        if let userId = userId, isAuthenticated {
            Task {
                do {
                    if favoriteMealIDs.contains(mealID) {
                        // Save to Firestore
                        if let meal = meals.first(where: { $0.idMeal == mealID }) ?? selectedMeal {
                            try await firestore.saveFavorite(userId: userId, meal: meal)
                        }
                    } else {
                        // Remove from Firestore
                        try await firestore.removeFavorite(userId: userId, mealId: mealID)
                    }
                } catch {
                    print("❌ Firestore sync error: \(error)")
                }
            }
        }
    }
    
    /// Load favorites from Firestore for authenticated users
    func loadFavoritesFromFirestore(userId: String) async {
        do {
            let favoriteIds = try await firestore.loadFavorites(userId: userId)
            await MainActor.run {
                self.favoriteMealIDs = favoriteIds
                self.saveFavorites()
                print("✅ Loaded \(favoriteIds.count) favorites from Firestore")
            }
        } catch {
            print("❌ Error loading favorites from Firestore: \(error)")
        }
    }
    
    /// Check if a meal is favorited
    func isFavorite(mealID: String) -> Bool {
        favoriteMealIDs.contains(mealID)
    }
    
    /// Load favorites from local storage
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteMealIDs = ids
        }
    }
    
    /// Save favorites to local storage
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteMealIDs) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
    
    // MARK: - Cookbook Management (with Firestore Sync)
    
    /// Save cooked meal to local + Firestore if authenticated
    func saveCookedMeal(meal: Meal, userId: String?, isAuthenticated: Bool) {
        let cookedMeal = CookedMeal(
            id: meal.idMeal,
            name: meal.strMeal,
            dateCooked: Date(),
            date: Date().formatted(date: .abbreviated, time: .omitted),
            rating: nil,
            notes: nil
        )
        
        // Save locally
        var cookbook: [CookedMeal] = []
        if let data = UserDefaults.standard.data(forKey: "cookbook"),
           let saved = try? JSONDecoder().decode([CookedMeal].self, from: data) {
            cookbook = saved
        }
        
        if !cookbook.contains(where: { $0.id == cookedMeal.id }) {
            cookbook.append(cookedMeal)
            if let data = try? JSONEncoder().encode(cookbook) {
                UserDefaults.standard.set(data, forKey: "cookbook")
                print("✅ Saved to local cookbook: \(meal.strMeal)")
                // Post notification to update CookbookView
                NotificationCenter.default.post(
                    name: NSNotification.Name("CookbookUpdated"),
                    object: nil
                )
            }
        }
        
        // Sync to Firestore if authenticated
        if let userId = userId, isAuthenticated {
            Task {
                do {
                    try await firestore.saveCookedMeal(userId: userId, meal: cookedMeal)
                } catch {
                    print("❌ Firestore sync error: \(error)")
                }
            }
        }
    }
    
    /// Update cooked meal rating/notes - local + Firestore if authenticated
    func updateCookedMeal(mealId: String, rating: Int, notes: String, userId: String?, isAuthenticated: Bool) {
        // Update locally
        var cookbook: [CookedMeal] = []
        if let data = UserDefaults.standard.data(forKey: "cookbook"),
           let saved = try? JSONDecoder().decode([CookedMeal].self, from: data) {
            cookbook = saved
        }
        
        if let index = cookbook.firstIndex(where: { $0.id == mealId }) {
            cookbook[index].rating = rating
            cookbook[index].notes = notes
            if let data = try? JSONEncoder().encode(cookbook) {
                UserDefaults.standard.set(data, forKey: "cookbook")
                print("✅ Updated local cookbook: \(mealId)")
                // Post notification to update CookbookView
                NotificationCenter.default.post(
                    name: NSNotification.Name("CookbookUpdated"),
                    object: nil
                )
            }
        }
        
        // Sync to Firestore if authenticated
        if let userId = userId, isAuthenticated {
            Task {
                do {
                    try await firestore.updateCookedMeal(userId: userId, mealId: mealId, rating: rating, notes: notes)
                } catch {
                    print("❌ Firestore sync error: \(error)")
                }
            }
        }
    }
    
    /// Load cookbook from Firestore for authenticated users
    func loadCookbookFromFirestore(userId: String) async -> [CookedMeal] {
        do {
            let meals = try await firestore.loadCookbook(userId: userId)
            if let data = try? JSONEncoder().encode(meals) {
                UserDefaults.standard.set(data, forKey: "cookbook")
                print("✅ Synced cookbook from Firestore to local")
            }
            return meals
        } catch {
            print("❌ Error loading cookbook from Firestore: \(error)")
            return []
        }
    }
}
