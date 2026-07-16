//  Cookbook.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ==============================================================
//  Description: Model for storing cooking history in UserDefaults
//  ==============================================================

import Foundation

// MARK: - Cooked Meal Model

/// Model for storing cooked meals in UserDefaults (local storage)
struct CookedMeal: Identifiable, Codable {
    // MARK: - Properties
    
    /// Meal ID from TheMealDB API
    let id: String
    
    /// Name of the meal
    let name: String
    
    /// Date when the meal was cooked
    let dateCooked: Date
    
    /// Formatted date string for display (e.g., "Jul 16, 2026")
    let date: String
    
    /// User's rating (1-5 stars, nil = not rated)
    var rating: Int?
    
    /// User's personal notes about the recipe
    var notes: String?
}
