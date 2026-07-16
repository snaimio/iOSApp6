//  OnboardingView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =====================================================================
//  Description: Professional onboarding screens showcasing key features
//  =====================================================================

import SwiftUI

struct OnboardingView: View {
    // MARK: - Properties
    
    /// UserDefaults key to track if onboarding has been shown
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    /// Current page index for page indicator
    @State private var currentPage = 0
    
    /// Onboarding page data - 3 screens highlighting key features
    let onboardingPages: [OnboardingPageData] = [
        OnboardingPageData(
            id: 0,
            image: "book.pages",
            title: "Recipe Library",
            subtitle: "Explore thousands of curated recipes from around the world",
            features: [
                "Browse by category or cuisine",
                "Smart search with instant results",
                "Save your favorite recipes"
            ],
            color: Color(red: 0.2, green: 0.6, blue: 0.3),
            gradientColors: [
                Color(red: 0.1, green: 0.5, blue: 0.2),
                Color(red: 0.3, green: 0.7, blue: 0.4)
            ]
        ),
        OnboardingPageData(
            id: 1,
            image: "list.number",
            title: "Guided Cooking",
            subtitle: "Follow step-by-step instructions with built-in timers",
            features: [
                "Interactive step-by-step guidance",
                "Smart timer detection and alerts",
                "Hands-free cooking experience"
            ],
            color: Color(red: 0.9, green: 0.5, blue: 0.1),
            gradientColors: [
                Color(red: 0.8, green: 0.4, blue: 0.05),
                Color(red: 1.0, green: 0.6, blue: 0.2)
            ]
        ),
        OnboardingPageData(
            id: 2,
            image: "heart.text.square",
            title: "Personal Cookbook",
            subtitle: "Build your culinary collection and track your progress",
            features: [
                "Rate recipes and add personal notes",
                "Track your cooking history",
                "Sync across all your devices"
            ],
            color: Color(red: 0.8, green: 0.2, blue: 0.3),
            gradientColors: [
                Color(red: 0.7, green: 0.15, blue: 0.2),
                Color(red: 0.9, green: 0.3, blue: 0.4)
            ]
        )
    ]
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - App Name Header
                HStack {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.green)
                    
                    Text("Nourishly")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                    
                    Spacer()
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // MARK: - Page Indicator
                HStack(spacing: 12) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.green : Color.gray.opacity(0.25))
                            .frame(width: currentPage == index ? 32 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 12)
                
                // MARK: - Page Content
                TabView(selection: $currentPage) {
                    ForEach(onboardingPages) { page in
                        OnboardingPageView(page: page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)
                
                // MARK: - Bottom Actions
                VStack(spacing: 16) {
                    if currentPage == onboardingPages.count - 1 {
                        // Last page - Get Started Button
                        Button {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                hasSeenOnboarding = true
                            }
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.6, blue: 0.3),
                                            Color(red: 0.1, green: 0.5, blue: 0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.green.opacity(0.3), radius: 12, x: 0, y: 4)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        // Previous pages - Skip and Continue buttons
                        HStack(spacing: 16) {
                            // Skip Button - allows user to bypass remaining pages
                            Button {
                                withAnimation(.spring()) {
                                    hasSeenOnboarding = true
                                }
                            } label: {
                                Text("Skip")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color(.systemGray6))
                                    )
                            }
                            
                            // Continue Button - advances to next page
                            Button {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    currentPage += 1
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    Text("Continue")
                                        .fontWeight(.semibold)
                                    Image(systemName: "arrow.right")
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 28)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.2, green: 0.6, blue: 0.3),
                                            Color(red: 0.1, green: 0.5, blue: 0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: Color.green.opacity(0.25), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 48)
            }
        }
    }
}

// MARK: - Onboarding Page Data

struct OnboardingPageData: Identifiable {
    let id: Int
    let image: String          // SF Symbol name
    let title: String          // Page title
    let subtitle: String       // Page description
    let features: [String]     // Key features list
    let color: Color           // Theme color for the page
    let gradientColors: [Color] // Gradient for the icon background
}

// MARK: - Onboarding Page View

struct OnboardingPageView: View {
    // MARK: - Properties
    
    let page: OnboardingPageData
    @State private var isAnimating = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 20)
            
            // MARK: - Hero Icon with Gradient Background
            ZStack {
                // Glow background effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                page.color.opacity(0.15),
                                page.color.opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 280)
                    .scaleEffect(isAnimating ? 1 : 0.9)
                    .animation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1), value: isAnimating)
                
                // Icon Container with Gradient
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: page.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: page.color.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: page.image)
                        .font(.system(size: 44, weight: .regular))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)
                }
                .scaleEffect(isAnimating ? 1 : 0.7)
                .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.2), value: isAnimating)
            }
            .padding(.bottom, 32)
            
            // MARK: - Text Content
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: isAnimating)
                
                Text(page.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1 : 0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: isAnimating)
            }
            .padding(.bottom, 28)
            
            // MARK: - Feature List
            VStack(alignment: .leading, spacing: 14) {
                ForEach(page.features, id: \.self) { feature in
                    HStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(page.color)
                            .symbolRenderingMode(.hierarchical)
                        
                        Text(feature)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal, 24)
            .opacity(isAnimating ? 1 : 0)
            .offset(y: isAnimating ? 0 : 30)
            .animation(.easeOut(duration: 0.5).delay(0.5), value: isAnimating)
            
            Spacer(minLength: 20)
        }
        .onAppear {
            // Trigger animations when view appears
            isAnimating = true
        }
        .onDisappear {
            // Reset animations when view disappears
            isAnimating = false
        }
    }
}

#Preview {
    OnboardingView()
}

