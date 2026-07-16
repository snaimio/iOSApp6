//  AuthChoiceView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  =========================================================================
//  Description: Screen allowing users to login/register or skip (guest mode)
//  =========================================================================

import SwiftUI

struct AuthChoiceView: View {
    // MARK: - Properties
    
    /// Shared authentication view model from parent
    @EnvironmentObject var authViewModel: AuthViewModel
    
    /// Shared meal data view model from parent
    @EnvironmentObject var mealViewModel: MealViewModel
    
    /// State for navigation to login screen
    @State private var showLogin = false
    
    /// State for navigation to register screen
    @State private var showRegister = false
    
    /// State for guest mode navigation
    @State private var isGuest = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // MARK: - App Logo
                VStack(spacing: 10) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
                    
                    Text("Nourishly")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Eat well. Live well.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // MARK: - Main Options
                VStack(spacing: 16) {
                    // Login Button
                    Button {
                        showLogin = true
                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Register Button
                    Button {
                        showRegister = true
                    } label: {
                        HStack {
                            Image(systemName: "person.badge.plus")
                            Text("Create Account")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // Guest Mode - Skip Button
                    NavigationLink {
                        MainTabView()
                            .environmentObject(authViewModel)
                            .environmentObject(mealViewModel)
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.xmark")
                            Text("Continue without account")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }
                    
                    Text("Your data will not be saved across devices")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
                    .environmentObject(authViewModel)
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AuthChoiceView()
        .environmentObject(AuthViewModel())
        .environmentObject(MealViewModel())
}
