//  Meal.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =====================================================
//  Description: Data models for meals from TheMealDB API
//  =====================================================

import Foundation

// MARK: - Response Wrapper

/// Response wrapper for meal API
struct MealResponse: Codable {
    let meals: [Meal]?
}

// MARK: - Meal Model

/// Main meal model containing all recipe data from TheMealDB API
struct Meal: Codable, Identifiable, Hashable {
    // MARK: - Basic Information
    
    /// Unique meal identifier
    let idMeal: String
    
    /// Name of the meal
    let strMeal: String
    
    /// Category (e.g., "Chicken", "Dessert")
    let strCategory: String?
    
    /// Cuisine/Area (e.g., "Japanese", "Italian")
    let strArea: String?
    
    /// Cooking instructions
    let strInstructions: String?
    
    /// URL to meal thumbnail image
    let strMealThumb: String?
    
    /// URL to YouTube video tutorial
    let strYoutube: String?
    
    // MARK: - Ingredients (20 possible pairs)
    
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?
    
    // MARK: - Measurements (20 possible pairs)
    
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?
    
    // MARK: - Identifiable Conformance
    
    var id: String { idMeal }
    
    // MARK: - Computed Properties
    
    /// Returns array of non-empty ingredient + measure pairs
    var ingredients: [(name: String, measure: String)] {
        let ingredients = [
            strIngredient1, strIngredient2, strIngredient3, strIngredient4,
            strIngredient5, strIngredient6, strIngredient7, strIngredient8,
            strIngredient9, strIngredient10, strIngredient11, strIngredient12,
            strIngredient13, strIngredient14, strIngredient15, strIngredient16,
            strIngredient17, strIngredient18, strIngredient19, strIngredient20
        ]
        
        let measures = [
            strMeasure1, strMeasure2, strMeasure3, strMeasure4,
            strMeasure5, strMeasure6, strMeasure7, strMeasure8,
            strMeasure9, strMeasure10, strMeasure11, strMeasure12,
            strMeasure13, strMeasure14, strMeasure15, strMeasure16,
            strMeasure17, strMeasure18, strMeasure19, strMeasure20
        ]
        
        var result: [(String, String)] = []
        
        for i in 0..<20 {
            let ingredient = ingredients[i]?.trimmingCharacters(in: .whitespacesAndNewlines)
            let measure = measures[i]?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let ingredient = ingredient, !ingredient.isEmpty,
               let measure = measure, !measure.isEmpty {
                result.append((ingredient, measure))
            }
        }
        
        return result
    }
    
    /// Returns instructions split into individual steps
    var instructionSteps: [String] {
        guard let instructions = strInstructions else { return [] }
        return instructions.components(separatedBy: ". ")
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}

// MARK: - Preview Helper

extension Meal {
    /// Sample meal for previews and testing
    static var previewMeal: Meal {
        Meal(
            idMeal: "52772",
            strMeal: "Teriyaki Chicken Casserole",
            strCategory: "Chicken",
            strArea: "Japanese",
            strInstructions: "Preheat oven to 350°F. Cook chicken and vegetables. Mix with rice and sauce. Bake for 30 minutes.",
            strMealThumb: "https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg",
            strYoutube: "https://www.youtube.com/watch?v=4aZr5hZXP_s",
            strIngredient1: "chicken",
            strIngredient2: "rice",
            strIngredient3: "soy sauce",
            strIngredient4: nil,
            strIngredient5: nil,
            strIngredient6: nil,
            strIngredient7: nil,
            strIngredient8: nil,
            strIngredient9: nil,
            strIngredient10: nil,
            strIngredient11: nil,
            strIngredient12: nil,
            strIngredient13: nil,
            strIngredient14: nil,
            strIngredient15: nil,
            strIngredient16: nil,
            strIngredient17: nil,
            strIngredient18: nil,
            strIngredient19: nil,
            strIngredient20: nil,
            strMeasure1: "2 cups",
            strMeasure2: "3 cups",
            strMeasure3: "1/2 cup",
            strMeasure4: nil,
            strMeasure5: nil,
            strMeasure6: nil,
            strMeasure7: nil,
            strMeasure8: nil,
            strMeasure9: nil,
            strMeasure10: nil,
            strMeasure11: nil,
            strMeasure12: nil,
            strMeasure13: nil,
            strMeasure14: nil,
            strMeasure15: nil,
            strMeasure16: nil,
            strMeasure17: nil,
            strMeasure18: nil,
            strMeasure19: nil,
            strMeasure20: nil
        )
    }
}
