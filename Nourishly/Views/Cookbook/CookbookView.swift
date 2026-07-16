//  CookbookView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ======================================================
//  Description: User's cooking history with saved recipes
//  ======================================================

import SwiftUI

struct CookbookView: View {
    // MARK: - Properties
    
    /// List of cooked meals from UserDefaults
    @State private var cookedMeals: [CookedMeal] = []
    
    /// Loading state while fetching cookbook data
    @State private var isLoading = true
    
    /// Whether to show the delete confirmation alert
    @State private var showingDeleteAlert = false
    
    /// The meal to delete
    @State private var mealToDelete: CookedMeal?
    
    /// The selected meal for rating
    @State private var selectedMeal: CookedMeal?
    
    /// Whether to show the rating sheet
    @State private var showingRatingSheet = false
    
    /// Full meal details for detail view
    @State private var selectedMealDetails: Meal?
    
    /// Loading state for meal details
    @State private var isLoadingDetails = false
    
    /// Whether to show the detail view
    @State private var showDetailView = false
    
    /// Trigger for refreshing the view
    @State private var refreshTrigger = UUID()
    
    /// Error message for alerts
    @State private var errorMessage: String?
    
    /// Whether to show the error alert
    @State private var showError = false
    
    /// Notification observer for cookbook updates
    @State private var updateObserver: Any?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    // Loading state
                    ProgressView("Loading your cookbook...")
                } else if cookedMeals.isEmpty {
                    // Empty state
                    emptyStateView
                } else {
                    // Cookbook list
                    cookbookListView
                }
            }
            .navigationTitle("Cookbook")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !cookedMeals.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        // Clear all cookbook entries
                        Button {
                            UserDefaults.standard.removeObject(forKey: "cookbook")
                            loadCookbook()
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .onAppear {
                loadCookbook()
                setupNotificationObserver()
            }
            .onDisappear {
                removeNotificationObserver()
            }
            .id(refreshTrigger)
            .alert("Delete Recipe?", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let meal = mealToDelete {
                        deleteMeal(meal)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this recipe from your cookbook?")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {
                    errorMessage = ""
                }
            } message: {
                Text(errorMessage ?? "An error occurred")
            }
            .sheet(isPresented: $showingRatingSheet) {
                if let meal = selectedMeal {
                    AddRatingView(
                        meal: meal,
                        onSave: { rating, notes in
                            print("📝 Received rating: \(rating), notes: \(notes)")
                            updateMeal(meal, rating: rating, notes: notes)
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: $showDetailView) {
                if let meal = selectedMealDetails {
                    NavigationStack {
                        CookbookDetailView(meal: meal)
                    }
                }
            }
            .overlay {
                if isLoadingDetails {
                    // Loading overlay for meal details
                    ProgressView("Loading recipe...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    /// View shown when cookbook is empty
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Your Cookbook is Empty")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Cook a recipe and it will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            NavigationLink {
                DiscoverView()
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
    
    /// List of cooked meals
    private var cookbookListView: some View {
        List {
            ForEach(cookedMeals) { meal in
                VStack(alignment: .leading, spacing: 8) {
                    // Main row - tappable to view recipe details
                    Button {
                        Task {
                            await loadMealDetails(mealId: meal.id)
                        }
                    } label: {
                        HStack {
                            Text(meal.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Show rating stars if rated
                            if let rating = meal.rating, rating > 0 {
                                HStack(spacing: 2) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < rating ? "star.fill" : "star")
                                            .font(.caption)
                                            .foregroundColor(index < rating ? .yellow : .gray)
                                    }
                                }
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Rating and Notes section
                    HStack {
                        if let rating = meal.rating, rating > 0 {
                            Text("Rating: \(rating)/5")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Not rated")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Rate / Edit Rating button
                        Button {
                            selectedMeal = meal
                            showingRatingSheet = true
                        } label: {
                            Label(meal.rating != nil ? "Edit Rating" : "Rate", systemImage: "star")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Date cooked
                    Text(meal.date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // User notes (if any)
                    if let notes = meal.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.vertical, 4)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    // Delete swipe action
                    Button(role: .destructive) {
                        mealToDelete = meal
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                    // Rate swipe action
                    Button {
                        selectedMeal = meal
                        showingRatingSheet = true
                    } label: {
                        Label(meal.rating != nil ? "Edit" : "Rate", systemImage: "star")
                    }
                    .tint(.yellow)
                }
            }
        }
        .refreshable {
            // Pull to refresh
            loadCookbook()
        }
    }
    
    // MARK: - Notification System
    
    /// Setup notification observer for cookbook updates
    func setupNotificationObserver() {
        updateObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("CookbookUpdated"),
            object: nil,
            queue: .main
        ) { _ in
            print("📢 Received cookbook update notification")
            loadCookbook()
            refreshTrigger = UUID()
        }
    }
    
    /// Remove notification observer
    func removeNotificationObserver() {
        if let observer = updateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Helper Functions
    
    /// Load cookbook from UserDefaults
    func loadCookbook() {
        isLoading = true
        
        if let data = UserDefaults.standard.data(forKey: "cookbook"),
           let meals = try? JSONDecoder().decode([CookedMeal].self, from: data) {
            cookedMeals = meals.sorted { $0.dateCooked > $1.dateCooked }
            print("📚 Loaded \(cookedMeals.count) meals from local cookbook")
        } else {
            cookedMeals = []
            print("📚 No cookbook data found")
        }
        
        isLoading = false
    }
    
    /// Delete a meal from cookbook
    func deleteMeal(_ meal: CookedMeal) {
        cookedMeals.removeAll { $0.id == meal.id }
        saveCookbook()
        print("🗑️ Deleted meal: \(meal.name)")
        refreshTrigger = UUID()
        postUpdateNotification()
    }
    
    /// Update a meal with rating and notes
    func updateMeal(_ meal: CookedMeal, rating: Int, notes: String) {
        print("📝 Updating meal: \(meal.name) with rating: \(rating), notes: \(notes)")
        
        if let index = cookedMeals.firstIndex(where: { $0.id == meal.id }) {
            cookedMeals[index].rating = rating
            cookedMeals[index].notes = notes
            print("✅ Updated meal at index \(index)")
            saveCookbook()
            refreshTrigger = UUID()
            loadCookbook()
            postUpdateNotification()
            print("✅ Meal updated and UI refreshed!")
        } else {
            print("❌ Meal not found in cookbook")
        }
    }
    
    /// Save cookbook to UserDefaults
    func saveCookbook() {
        do {
            let data = try JSONEncoder().encode(cookedMeals)
            UserDefaults.standard.set(data, forKey: "cookbook")
            print("💾 Saved \(cookedMeals.count) meals to cookbook")
        } catch {
            print("❌ Error saving cookbook: \(error)")
        }
    }
    
    /// Post notification to update other views
    func postUpdateNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name("CookbookUpdated"),
            object: nil
        )
    }
    
    /// Load meal details for detail view
    func loadMealDetails(mealId: String) async {
        isLoadingDetails = true
        errorMessage = nil
        
        do {
            print("🔍 Fetching meal details for ID: \(mealId)")
            let meal = try await MealService.shared.fetchMealDetail(id: mealId)
            await MainActor.run {
                selectedMealDetails = meal
                isLoadingDetails = false
                showDetailView = true
                print("✅ Successfully loaded meal: \(meal.strMeal)")
            }
        } catch {
            print("❌ Error loading meal details: \(error)")
            await MainActor.run {
                errorMessage = "Could not load recipe details. Please try again."
                showError = true
                isLoadingDetails = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    CookbookView()
}
