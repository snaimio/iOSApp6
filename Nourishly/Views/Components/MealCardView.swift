//  MealCardView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ==========================================================================
//  Description: Reusable meal card component for displaying meal information
//  ==========================================================================

import SwiftUI

struct MealCardView: View {
    // MARK: - Properties
    
    /// The meal to display
    let meal: Meal
    
    /// Whether the meal is favorited
    let isFavorite: Bool
    
    /// Callback when the favorite button is tapped
    let onFavoriteToggle: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 12) {
            // MARK: - Meal Image
            if let imageURL = meal.strMealThumb,
               let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // Loading state
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    case .success(let image):
                        // Loaded image
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .clipped()
                    case .failure:
                        // Error state - show placeholder
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // MARK: - Meal Info
            VStack(alignment: .leading, spacing: 4) {
                // Meal name
                Text(meal.strMeal)
                    .font(.headline)
                    .lineLimit(2)
                
                // Category and cuisine
                HStack {
                    if let category = meal.strCategory {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let area = meal.strArea {
                        Text("• \(area)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // MARK: - Favorite Button
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .red : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    MealCardView(
        meal: Meal.previewMeal,
        isFavorite: true,
        onFavoriteToggle: {}
    )
}
