//  AddRatingView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ====================================================
//  Description: Rating and notes view for cooked meals
//  ====================================================

import SwiftUI

struct AddRatingView: View {
    // MARK: - Properties
    
    /// The cooked meal to rate
    let meal: CookedMeal
    
    /// Save callback with rating and notes
    let onSave: (Int, String) -> Void
    
    /// Current rating value (1-5)
    @State private var rating: Int
    
    /// User's notes about the recipe
    @State private var notes: String
    
    /// Dismiss environment to close the sheet
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Initialization
    
    init(meal: CookedMeal, onSave: @escaping (Int, String) -> Void) {
        self.meal = meal
        self.onSave = onSave
        // Initialize with existing rating and notes if available
        _rating = State(initialValue: meal.rating ?? 0)
        _notes = State(initialValue: meal.notes ?? "")
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Meal Header
                    VStack(spacing: 8) {
                        // Meal Image (placeholder since we don't store images in CookedMeal)
                        placeholderImage
                        
                        // Meal Name
                        Text(meal.name.isEmpty ? "Unknown Recipe" : meal.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    
                    // MARK: - Rating Section
                    VStack(spacing: 16) {
                        Text("How was this recipe?")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Interactive star rating
                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { index in
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        rating = index
                                    }
                                } label: {
                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                        .font(.system(size: 44))
                                        .foregroundColor(index <= rating ? .yellow : .gray.opacity(0.3))
                                        .scaleEffect(index <= rating ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: rating)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Rating feedback text
                        Text(rating == 0 ? "Tap a star to rate" : "\(rating) out of 5 stars")
                            .font(.subheadline)
                            .foregroundColor(rating == 0 ? .secondary : .yellow)
                            .fontWeight(rating > 0 ? .semibold : .regular)
                    }
                    .padding(.horizontal, 20)
                    
                    // MARK: - Notes Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "pencil")
                                .foregroundColor(.gray)
                            Text("Your Notes")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Notes text editor with placeholder
                        ZStack(alignment: .topLeading) {
                            TextEditor(text: $notes)
                                .frame(height: 120)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                                )
                                .font(.body)
                            
                            if notes.isEmpty {
                                Text("What did you think? Any tips for next time?")
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 20)
                                    .font(.body)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 20)
                    
                    // MARK: - Save Button
                    Button {
                        print("📝 Saving rating: \(rating), notes: \(notes)")
                        onSave(rating, notes)
                        // Post notification to refresh Cookbook
                        NotificationCenter.default.post(
                            name: NSNotification.Name("CookbookUpdated"),
                            object: nil
                        )
                        dismiss()
                    } label: {
                        HStack {
                            if rating > 0 {
                                Image(systemName: "checkmark.circle.fill")
                            }
                            Text(rating > 0 ? "Save Review" : "Add Rating")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: rating > 0 ? [Color.green, Color.green.opacity(0.7)] : [Color.gray, Color.gray.opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: rating > 0 ? Color.green.opacity(0.3) : Color.clear, radius: 10, x: 0, y: 4)
                    }
                    .padding(.horizontal, 20)
                    .disabled(rating == 0) // Must select a rating to save
                    .padding(.bottom, 20)
                }
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Rate & Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Helper Views
    
    /// Placeholder image when no meal image is available
    private var placeholderImage: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [Color.green.opacity(0.15), Color.green.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 120)
            .overlay {
                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(.green.opacity(0.3))
            }
            .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    AddRatingView(
        meal: CookedMeal(
            id: "1",
            name: "Fennel Dauphinoise",
            dateCooked: Date(),
            date: "Today",
            rating: nil,
            notes: nil
        ),
        onSave: { rating, notes in
            print("Rating: \(rating), Notes: \(notes)")
        }
    )
}
