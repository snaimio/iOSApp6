//  CookbookDetailView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =============================================
//  Description: Detail view for cookbook recipes
//  =============================================

import SwiftUI

struct CookbookDetailView: View {
    // MARK: - Properties
    
    /// The meal to display
    let meal: Meal
    
    /// Dismiss environment to close the view
    @Environment(\.dismiss) var dismiss
    
    /// Whether to show the rating view sheet
    @State private var showRatingView = false
    
    /// The cooked meal data from the cookbook
    @State private var cookedMeal: CookedMeal?
    
    /// Flag to prevent multiple loads
    @State private var hasLoaded = false
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Hero Image
                if let url = URL(string: meal.strMealThumb ?? "") {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            // Loading state
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 250)
                                .overlay(ProgressView())
                        case .success(let image):
                            // Loaded image
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        case .failure:
                            // Error state - show placeholder
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 250)
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    // MARK: - Recipe Name
                    Text(meal.strMeal)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // MARK: - Rating and Rate Button
                    HStack {
                        // Display current rating if exists
                        if let cookedMeal = cookedMeal, let rating = cookedMeal.rating, rating > 0 {
                            HStack(spacing: 2) {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < rating ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundColor(index < rating ? .yellow : .gray)
                                }
                            }
                        } else {
                            Text("Not rated")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Rate / Edit Rating Button
                        Button {
                            loadCookedMealAndShowRating()
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                Text(cookedMeal?.rating != nil ? "Edit Rating" : "Rate This Recipe")
                            }
                            .font(.subheadline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.yellow.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(8)
                        }
                    }
                    
                    // MARK: - Metadata (Category, Cuisine)
                    HStack(spacing: 16) {
                        if let category = meal.strCategory {
                            Label(category, systemImage: "tag")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let area = meal.strArea {
                            Label(area, systemImage: "globe")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // MARK: - Ingredients Section
                    if !meal.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🛒 Ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(meal.ingredients, id: \.name) { ingredient in
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .font(.caption2)
                                        .foregroundColor(.green)
                                    
                                    Text(ingredient.measure)
                                        .fontWeight(.medium)
                                    
                                    Text(ingredient.name)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // MARK: - Instructions Section
                    if !meal.instructionSteps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📖 Instructions")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            // Numbered steps for easy reading
                            ForEach(Array(meal.instructionSteps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    // Step number circle
                                    Text("\(index + 1)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                        .frame(width: 30, height: 30)
                                        .background(Color.green.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    Text(step)
                                        .padding(.top, 4)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // MARK: - YouTube Video Link
                    if let youtubeURL = meal.strYoutube,
                       let url = URL(string: youtubeURL) {
                        Link(destination: url) {
                            Label("Watch on YouTube 📺", systemImage: "play.rectangle.fill")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    // MARK: - Cook Again Button
                    NavigationLink {
                        CookModeView(meal: meal)
                    } label: {
                        Label("👨‍🍳 Cook Again", systemImage: "flame.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.red],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Close button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .sheet(isPresented: $showRatingView) {
            if let meal = cookedMeal {
                AddRatingView(
                    meal: meal,
                    onSave: { rating, notes in
                        updateCookbook(mealId: meal.id, rating: rating, notes: notes)
                        // Update local state immediately
                        cookedMeal?.rating = rating
                        cookedMeal?.notes = notes
                    }
                )
            }
        }
        .onAppear {
            // Only load once to avoid unnecessary refreshes
            if !hasLoaded {
                loadCookedMeal()
                hasLoaded = true
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Load the cooked meal from UserDefaults
    func loadCookedMeal() {
        if let data = UserDefaults.standard.data(forKey: "cookbook"),
           let meals = try? JSONDecoder().decode([CookedMeal].self, from: data) {
            cookedMeal = meals.first(where: { $0.id == meal.idMeal })
            print("📚 Found cooked meal: \(cookedMeal?.name ?? "nil")")
        } else {
            print("📚 No cookbook data found")
        }
    }
    
    /// Load the cooked meal and show the rating sheet
    func loadCookedMealAndShowRating() {
        // Load the meal first
        loadCookedMeal()
        
        // If meal still nil, create a temporary one for rating
        if cookedMeal == nil {
            cookedMeal = CookedMeal(
                id: meal.idMeal,
                name: meal.strMeal,
                dateCooked: Date(),
                date: Date().formatted(date: .abbreviated, time: .omitted),
                rating: nil,
                notes: nil
            )
        }
        
        // Show the rating sheet
        showRatingView = true
    }
    
    /// Update the cookbook with rating and notes
    func updateCookbook(mealId: String, rating: Int, notes: String) {
        // Update local UserDefaults
        if let data = UserDefaults.standard.data(forKey: "cookbook"),
           var meals = try? JSONDecoder().decode([CookedMeal].self, from: data) {
            if let index = meals.firstIndex(where: { $0.id == mealId }) {
                meals[index].rating = rating
                meals[index].notes = notes
                if let newData = try? JSONEncoder().encode(meals) {
                    UserDefaults.standard.set(newData, forKey: "cookbook")
                    print("✅ Updated cookbook with rating: \(rating), notes: \(notes)")
                    
                    // Post notification to refresh other views
                    NotificationCenter.default.post(
                        name: NSNotification.Name("CookbookUpdated"),
                        object: nil
                    )
                }
            }
        }
        
        // Update local state
        if cookedMeal != nil {
            cookedMeal?.rating = rating
            cookedMeal?.notes = notes
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CookbookDetailView(meal: Meal.previewMeal)
    }
}
