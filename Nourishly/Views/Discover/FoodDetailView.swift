//  FoodDetailView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ======================================================================================
//  Description: Full recipe detail view with ingredients, instructions, and cooking time
//  ======================================================================================

import SwiftUI

struct FoodDetailView: View {
    // MARK: - Properties
    
    /// The meal to display
    let meal: Meal
    
    /// Shared meal data view model from parent
    @EnvironmentObject var mealViewModel: MealViewModel
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// Full meal details fetched from API (if needed)
    @State private var fullMeal: Meal?
    
    /// Loading state for fetching full details
    @State private var isLoading = false
    
    /// Error message if fetching fails
    @State private var errorMessage: String?
    
    // MARK: - Body
    
    var body: some View {
        // Use full meal if loaded, otherwise use the passed meal
        let displayMeal = fullMeal ?? meal
        
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: - Hero Image
                if let url = URL(string: displayMeal.strMealThumb ?? "") {
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
                    Text(displayMeal.strMeal)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // MARK: - Metadata (Category, Cuisine)
                    HStack(spacing: 16) {
                        if let category = displayMeal.strCategory {
                            Label(category, systemImage: "tag")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if let area = displayMeal.strArea {
                            Label(area, systemImage: "globe")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // MARK: - Cooking Time (Estimated from instructions)
                    HStack(spacing: 16) {
                        Label("⏱️ ~\(estimateCookingTime(from: displayMeal.strInstructions ?? "")) min", systemImage: "clock")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // MARK: - Favorite Button
                    // Requires authentication - guests will see an alert
                    Button {
                        mealViewModel.toggleFavorite(
                            mealID: displayMeal.idMeal,
                            userId: authViewModel.userId,
                            isAuthenticated: authViewModel.isAuthenticated
                        )
                    } label: {
                        Label(
                            mealViewModel.isFavorite(mealID: displayMeal.idMeal) ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: mealViewModel.isFavorite(mealID: displayMeal.idMeal) ? "heart.fill" : "heart"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(mealViewModel.isFavorite(mealID: displayMeal.idMeal) ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .alert("Sign In Required", isPresented: $mealViewModel.showAuthAlert) {
                        Button("OK") { }
                    } message: {
                        Text("Please sign in or create an account to save favorites.")
                    }
                    
                    // MARK: - Ingredients Section
                    if !displayMeal.ingredients.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("🛒 Ingredients")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            ForEach(displayMeal.ingredients, id: \.name) { ingredient in
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
                    if !displayMeal.instructionSteps.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📖 Instructions")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            // Numbered steps for easy reading
                            ForEach(Array(displayMeal.instructionSteps.enumerated()), id: \.offset) { index, step in
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
                    } else {
                        // Show message if no instructions available
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📖 Instructions")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if isLoading {
                                // Loading instructions
                                HStack {
                                    ProgressView()
                                        .padding(.trailing, 8)
                                    Text("Loading instructions...")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            } else if let error = errorMessage {
                                // Error state
                                Text("Error: \(error)")
                                    .foregroundColor(.red)
                                    .padding(.vertical, 8)
                            } else {
                                // No instructions available
                                Text("No cooking instructions available for this recipe.")
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // MARK: - YouTube Video Link
                    if let youtubeURL = displayMeal.strYoutube,
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
                    
                    // MARK: - Cook Mode Button
                    // Only enabled if instructions are available
                    if !displayMeal.instructionSteps.isEmpty {
                        NavigationLink {
                            CookModeView(meal: displayMeal)
                                .environmentObject(mealViewModel)
                                .environmentObject(authViewModel)
                        } label: {
                            Label("👨‍🍳 Start Cooking", systemImage: "flame.fill")
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
                    } else {
                        // Disabled button if no instructions
                        Label("No Instructions Available", systemImage: "flame.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .foregroundColor(.secondary)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            // Fetch full meal details if the current meal doesn't have instructions
            if meal.strInstructions == nil || meal.strInstructions?.isEmpty == true {
                await loadFullMealDetails()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// Fetch full meal details using the meal ID
    func loadFullMealDetails() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedMeal = try await MealService.shared.fetchMealDetail(id: meal.idMeal)
            await MainActor.run {
                self.fullMeal = fetchedMeal
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    /// Estimate cooking time based on instruction text
    /// - Parameter instructions: The instruction text to parse
    /// - Returns: Estimated cooking time in minutes, defaults to 30 if not found
    func estimateCookingTime(from instructions: String) -> Int {
        let timeKeywords = ["minute", "minutes", "min", "mins", "hour", "hours", "hr", "hrs"]
        var totalTime = 0
        
        // Search for time keywords in instructions
        for keyword in timeKeywords {
            let pattern = "\\b(\\d+)\\s*\(keyword)"
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let matches = regex.matches(in: instructions, range: NSRange(instructions.startIndex..., in: instructions))
                for match in matches {
                    if let range = Range(match.range(at: 1), in: instructions) {
                        let number = Int(instructions[range]) ?? 0
                        // Convert hours to minutes if needed
                        if keyword.contains("hour") || keyword.contains("hr") {
                            totalTime += number * 60
                        } else {
                            totalTime += number
                        }
                    }
                }
            }
        }
        
        return totalTime > 0 ? totalTime : 30 // Default to 30 minutes
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FoodDetailView(meal: Meal.previewMeal)
            .environmentObject(MealViewModel())
            .environmentObject(AuthViewModel())
    }
}
