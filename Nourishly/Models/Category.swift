//  Category.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ==============================================================
//  Description: Data model for meal categories from TheMealDB API
//  ==============================================================

import Foundation

// MARK: - Response Wrapper

/// Response wrapper for category API
struct CategoryResponse: Codable {
    let categories: [Category]
}

// MARK: - Category Model

/// Category model representing a meal category from TheMealDB API
struct Category: Codable, Identifiable {
    // MARK: - Properties
    
    /// Unique category identifier
    let idCategory: String
    
    /// Category name (e.g., "Beef", "Chicken", "Dessert")
    let strCategory: String
    
    /// URL to category thumbnail image
    let strCategoryThumb: String
    
    /// Description of the category
    let strCategoryDescription: String
    
    // MARK: - Identifiable Conformance
    
    var id: String { idCategory }
}
