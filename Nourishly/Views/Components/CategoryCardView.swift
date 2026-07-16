//  CategoryCardView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =====================================================================
//  Description: Beautiful category card component with gradient overlay
//  =====================================================================

import SwiftUI

struct CategoryCardView: View {
    // MARK: - Properties
    
    /// The category to display
    let category: Category
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Category Image
            let imageURL = category.strCategoryThumb
            if !imageURL.isEmpty, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        // Loading state
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(1.2, contentMode: .fit)
                            .overlay {
                                ProgressView()
                                    .tint(.green)
                            }
                    case .success(let image):
                        // Loaded image
                        image
                            .resizable()
                            .aspectRatio(1.2, contentMode: .fill)
                            .clipped()
                    case .failure:
                        // Error state - show gradient placeholder with icon
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .aspectRatio(1.2, contentMode: .fit)
                            .overlay {
                                Image(systemName: "fork.knife")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            }
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Fallback when no image URL is available
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(1.2, contentMode: .fit)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    }
            }
            
            // MARK: - Category Name (Card Footer)
            Text(category.strCategory)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .cornerRadius(16)
        .shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview

#Preview {
    CategoryCardView(
        category: Category(
            idCategory: "1",
            strCategory: "Beef",
            strCategoryThumb: "https://www.themealdb.com/images/category/beef.png",
            strCategoryDescription: "Beef dishes"
        )
    )
    .frame(width: 170, height: 200)
    .padding()
}
