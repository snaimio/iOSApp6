//  Color+Extensions.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ====================================================================
//  Description: Color extensions for consistent theming across the app
//  ====================================================================

import SwiftUI

// MARK: - Color Extensions

extension Color {
    // MARK: - Brand Colors
    
    /// Primary green color for the app branding
    static let nourishGreen = Color("NourishGreen")
    
    /// Secondary orange color for accents
    static let nourishOrange = Color("NourishOrange")
    
    /// Cream color for backgrounds
    static let nourishCream = Color("NourishCream")
    
    // MARK: - Fallback Colors
    
    /// Fallback green (used if asset color is missing)
    static let nourishGreenFallback = Color(red: 0.56, green: 0.75, blue: 0.56)
    
    /// Fallback orange (used if asset color is missing)
    static let nourishOrangeFallback = Color(red: 0.96, green: 0.64, blue: 0.38)
}
