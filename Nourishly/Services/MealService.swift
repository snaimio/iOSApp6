//  MealService.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ========================================================
//  Description: Handles all TheMealDB API network requests
//  ========================================================

import Foundation

// MARK: - Custom Error Types

/// Custom error types for meal service
enum MealServiceError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL. Please try again."
        case .noData:
            return "No data received from server."
        case .decodingError:
            return "Error parsing data. Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Meal Service

/// Service class for all TheMealDB API operations
class MealService {
    // MARK: - Singleton
    
    static let shared = MealService()
    
    // MARK: - Constants
    
    /// Base URL with free test API key "1"
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Categories
    
    /// Fetches all meal categories
    /// - Returns: Array of Category objects
    /// - Throws: MealServiceError if the request fails
    func fetchCategories() async throws -> [Category] {
        guard let url = URL(string: "\(baseURL)/categories.php") else {
            throw MealServiceError.invalidURL
        }
        
        print("🌐 Fetching categories from: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MealServiceError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            let categoryResponse = try decoder.decode(CategoryResponse.self, from: data)
            print("✅ Received \(categoryResponse.categories.count) categories")
            return categoryResponse.categories
        } catch {
            print("❌ Decoding error: \(error)")
            throw MealServiceError.decodingError
        }
    }
    
    // MARK: - Meals by Category
    
    /// Fetches meals by category name (summary data - no instructions)
    /// - Parameter category: The category name (e.g., "Beef", "Chicken")
    /// - Returns: Array of Meal objects (summary)
    /// - Throws: MealServiceError if the request fails
    func fetchMealsByCategory(_ category: String) async throws -> [Meal] {
        guard let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/filter.php?c=\(encodedCategory)") else {
            throw MealServiceError.invalidURL
        }
        
        print("🌐 Fetching meals for category '\(category)' from: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MealServiceError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            let mealResponse = try decoder.decode(MealResponse.self, from: data)
            let meals = mealResponse.meals ?? []
            print("✅ Received \(meals.count) meals for category '\(category)'")
            return meals
        } catch {
            print("❌ Decoding error for category '\(category)': \(error)")
            throw MealServiceError.decodingError
        }
    }
    
    // MARK: - Meal Details (Full Recipe)
    
    /// Fetches full meal details by ID (includes instructions and all ingredients)
    /// - Parameter id: The meal ID (e.g., "52772")
    /// - Returns: Full Meal object with instructions and all ingredients
    /// - Throws: MealServiceError if the request fails
    func fetchMealDetail(id: String) async throws -> Meal {
        guard let url = URL(string: "\(baseURL)/lookup.php?i=\(id)") else {
            throw MealServiceError.invalidURL
        }
        
        print("🌐 Fetching meal details for ID: \(id)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MealServiceError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            let mealResponse = try decoder.decode(MealResponse.self, from: data)
            guard let meal = mealResponse.meals?.first else {
                throw MealServiceError.noData
            }
            print("✅ Fetched meal: \(meal.strMeal)")
            return meal
        } catch {
            print("❌ Decoding error for meal ID \(id): \(error)")
            throw MealServiceError.decodingError
        }
    }
    
    // MARK: - Search
    
    /// Searches meals by name
    /// - Parameter query: The search query (e.g., "chicken")
    /// - Returns: Array of matching Meal objects
    /// - Throws: MealServiceError if the request fails
    func searchMeals(query: String) async throws -> [Meal] {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/search.php?s=\(encodedQuery)") else {
            throw MealServiceError.invalidURL
        }
        
        print("🌐 Searching meals for query: \(query)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MealServiceError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            let mealResponse = try decoder.decode(MealResponse.self, from: data)
            let meals = mealResponse.meals ?? []
            print("✅ Found \(meals.count) meals for query: \(query)")
            return meals
        } catch {
            print("❌ Decoding error for search query '\(query)': \(error)")
            throw MealServiceError.decodingError
        }
    }
    
    // MARK: - Random Meal
    
    /// Fetches a random meal (full details)
    /// - Returns: Full Meal object with instructions and all ingredients
    /// - Throws: MealServiceError if the request fails
    func fetchRandomMeal() async throws -> Meal {
        guard let url = URL(string: "\(baseURL)/random.php") else {
            throw MealServiceError.invalidURL
        }
        
        print("🌐 Fetching random meal")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw MealServiceError.noData
        }
        
        do {
            let decoder = JSONDecoder()
            let mealResponse = try decoder.decode(MealResponse.self, from: data)
            guard let meal = mealResponse.meals?.first else {
                throw MealServiceError.noData
            }
            print("✅ Random meal: \(meal.strMeal)")
            return meal
        } catch {
            print("❌ Decoding error for random meal: \(error)")
            throw MealServiceError.decodingError
        }
    }
}
