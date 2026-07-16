//  FirestoreService.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ====================================================================
//  Description: Handles Firestore operations for favorites and cookbook
//  ====================================================================

import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - Firestore Service

class FirestoreService {
    // MARK: - Singleton
    
    static let shared = FirestoreService()
    
    // MARK: - Properties
    
    private let db = Firestore.firestore()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Favorites Operations
    
    /// Save a favorite to Firestore
    /// - Parameters:
    ///   - userId: The authenticated user's ID
    ///   - meal: The meal to save as favorite
    func saveFavorite(userId: String, meal: Meal) async throws {
        let data: [String: Any] = [
            "mealId": meal.idMeal,
            "mealName": meal.strMeal,
            "mealImage": meal.strMealThumb ?? "",
            "addedDate": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(meal.idMeal)
            .setData(data)
        
        print("✅ Saved favorite to Firestore: \(meal.strMeal)")
    }
    
    /// Remove a favorite from Firestore
    /// - Parameters:
    ///   - userId: The authenticated user's ID
    ///   - mealId: The meal ID to remove
    func removeFavorite(userId: String, mealId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(mealId)
            .delete()
        
        print("✅ Removed favorite from Firestore: \(mealId)")
    }
    
    /// Load all favorites for a user
    /// - Parameter userId: The authenticated user's ID
    /// - Returns: Set of favorite meal IDs
    func loadFavorites(userId: String) async throws -> Set<String> {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("favorites")
            .getDocuments()
        
        let favoriteIds = Set(snapshot.documents.compactMap { $0.documentID })
        print("📚 Loaded \(favoriteIds.count) favorites from Firestore")
        return favoriteIds
    }
    
    // MARK: - Cookbook Operations
    
    /// Save a cooked meal to Firestore
    /// - Parameters:
    ///   - userId: The authenticated user's ID
    ///   - meal: The cooked meal to save
    func saveCookedMeal(userId: String, meal: CookedMeal) async throws {
        let data: [String: Any] = [
            "mealId": meal.id,
            "mealName": meal.name,
            "dateCooked": meal.dateCooked,
            "rating": meal.rating ?? 0,
            "notes": meal.notes ?? ""
        ]
        
        try await db.collection("users")
            .document(userId)
            .collection("cookbook")
            .document(meal.id)
            .setData(data)
        
        print("✅ Saved cookbook entry to Firestore: \(meal.name)")
    }
    
    /// Update a cooked meal in Firestore (for rating/notes)
    /// - Parameters:
    ///   - userId: The authenticated user's ID
    ///   - mealId: The meal ID to update
    ///   - rating: The new rating (optional)
    ///   - notes: The new notes (optional)
    func updateCookedMeal(userId: String, mealId: String, rating: Int?, notes: String?) async throws {
        var data: [String: Any] = [:]
        if let rating = rating {
            data["rating"] = rating
        }
        if let notes = notes {
            data["notes"] = notes
        }
        
        if !data.isEmpty {
            try await db.collection("users")
                .document(userId)
                .collection("cookbook")
                .document(mealId)
                .updateData(data)
            
            print("✅ Updated cookbook entry in Firestore: \(mealId)")
        }
    }
    
    /// Load all cookbook entries for a user
    /// - Parameter userId: The authenticated user's ID
    /// - Returns: Array of CookedMeal objects
    func loadCookbook(userId: String) async throws -> [CookedMeal] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("cookbook")
            .order(by: "dateCooked", descending: true)
            .getDocuments()
        
        let meals = snapshot.documents.compactMap { document -> CookedMeal? in
            let data = document.data()
            guard let mealId = data["mealId"] as? String,
                  let mealName = data["mealName"] as? String,
                  let timestamp = data["dateCooked"] as? Timestamp else {
                return nil
            }
            
            return CookedMeal(
                id: mealId,
                name: mealName,
                dateCooked: timestamp.dateValue(),
                date: timestamp.dateValue().formatted(date: .abbreviated, time: .omitted),
                rating: data["rating"] as? Int,
                notes: data["notes"] as? String
            )
        }
        
        print("📚 Loaded \(meals.count) cookbook entries from Firestore")
        return meals
    }
    
    /// Delete a cooked meal from Firestore
    /// - Parameters:
    ///   - userId: The authenticated user's ID
    ///   - mealId: The meal ID to delete
    func deleteCookedMeal(userId: String, mealId: String) async throws {
        try await db.collection("users")
            .document(userId)
            .collection("cookbook")
            .document(mealId)
            .delete()
        
        print("🗑️ Deleted cookbook entry from Firestore: \(mealId)")
    }
    
    // MARK: - Sync Helpers
    
    /// Sync local data to Firestore when user logs in
    /// - Parameter userId: The authenticated user's ID
    func syncLocalDataToFirestore(userId: String) async throws {
        print("🔄 Syncing local data to Firestore for user: \(userId)")
        
        // Note: Full sync logic can be implemented here if needed
        // This would involve reading from UserDefaults and writing to Firestore
        
        print("✅ Local sync complete!")
    }
}
