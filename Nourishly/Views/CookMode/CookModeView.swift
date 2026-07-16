//  CookModeView.swift
//  Nourishly

//  Created by Sheikh Naim on 2026-07-16.

//  ===================================================================
//  Description: Step-by-step guided cooking mode with timer and sound
//  ===================================================================

import SwiftUI
import AVFoundation

struct CookModeView: View {
    // MARK: - Properties
    
    /// The meal being cooked
    let meal: Meal
    
    /// Dismiss environment to close the view
    @Environment(\.dismiss) var dismiss
    
    /// Current step index (0-based)
    @State private var currentStep = 0
    
    /// Set of completed step indices
    @State private var completedSteps: Set<Int> = []
    
    // MARK: - Timer Properties
    
    /// Total timer duration in seconds
    @State private var timerSeconds = 0
    
    /// Remaining time on timer in seconds
    @State private var timerRemaining = 0
    
    /// Whether the timer is currently running
    @State private var isTimerRunning = false
    
    /// Name/description of the current timer
    @State private var timerName = ""
    
    /// Whether to show the timer finished alert
    @State private var showingTimerAlert = false
    
    /// Whether the timer has finished
    @State private var timerFinished = false
    
    /// The timer instance
    @State private var timerID: Timer?
    
    // MARK: - Body
    
    var body: some View {
        // Safety check: if no instructions, show error
        if meal.instructionSteps.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                Text("No instructions available for this recipe")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Button("Go Back") {
                    dismiss()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .navigationTitle("Cooking Mode")
            .navigationBarTitleDisplayMode(.inline)
        } else {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header with Progress
                    VStack(spacing: 12) {
                        // Recipe name
                        Text(meal.strMeal)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Progress bar
                        VStack(spacing: 8) {
                            HStack {
                                Text("Step \(currentStep + 1) of \(meal.instructionSteps.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("\(completedSteps.count) / \(meal.instructionSteps.count)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            
                            ProgressView(value: Double(completedSteps.count), total: Double(meal.instructionSteps.count))
                                .tint(.green)
                                .animation(.easeInOut, value: completedSteps.count)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Current Step Card
                    VStack(spacing: 20) {
                        // Step number indicator
                        HStack {
                            Image(systemName: "\(currentStep + 1).circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            Text("Current Step")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Step instruction text
                        Text(meal.instructionSteps[currentStep])
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.leading)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Timer Section
                    if containsTime(in: meal.instructionSteps[currentStep]) {
                        VStack(spacing: 12) {
                            Divider()
                                .padding(.horizontal)
                            
                            HStack {
                                Label("Timer", systemImage: "timer")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            if isTimerRunning || timerRemaining > 0 {
                                // Timer display when running or has remaining time
                                HStack(spacing: 20) {
                                    Image(systemName: "hourglass")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    Text(timeString(from: timerRemaining))
                                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                                        .foregroundColor(.blue)
                                    
                                    if isTimerRunning {
                                        Button {
                                            stopTimer()
                                        } label: {
                                            Image(systemName: "stop.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.08))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            } else {
                                // Start timer button
                                Button {
                                    extractTimeAndStartTimer(from: meal.instructionSteps[currentStep])
                                } label: {
                                    HStack {
                                        Image(systemName: "play.circle.fill")
                                            .font(.title2)
                                        Text("Start Timer")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // MARK: - Navigation Buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            // Previous button
                            if currentStep > 0 {
                                Button {
                                    withAnimation {
                                        stopTimer()
                                        currentStep -= 1
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Previous")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.gray.opacity(0.15))
                                    .cornerRadius(12)
                                }
                            }
                            
                            // Next / Done button
                            if currentStep < meal.instructionSteps.count - 1 {
                                // Next button
                                Button {
                                    withAnimation {
                                        stopTimer()
                                        completedSteps.insert(currentStep)
                                        currentStep += 1
                                    }
                                } label: {
                                    HStack {
                                        Text("Next")
                                        Image(systemName: "chevron.right")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            } else {
                                // Done button - saves to cookbook
                                Button {
                                    stopTimer()
                                    completedSteps.insert(currentStep)
                                    saveToCookbook(meal: meal)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Done! 🎉")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [Color.green, Color.green.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("Cooking Mode")
            .navigationBarTitleDisplayMode(.inline)
            .alert("⏰ Timer Finished!", isPresented: $showingTimerAlert) {
                Button("OK") {
                    timerFinished = true
                    timerRemaining = 0
                }
            } message: {
                Text("Your timer for \(timerName) has finished!")
            }
            .onDisappear {
                // Clean up timer when view disappears
                stopTimer()
            }
        }
    }
    
    // MARK: - Timer Helper Functions
    
    /// Format seconds to MM:SS string
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    /// Check if instruction contains time keywords
    func containsTime(in instruction: String) -> Bool {
        let timeWords = ["minute", "minutes", "min", "mins", "hour", "hours", "second", "seconds"]
        return timeWords.contains { instruction.lowercased().contains($0) }
    }
    
    /// Extract time from instruction and start timer
    func extractTimeAndStartTimer(from instruction: String) {
        let words = instruction.components(separatedBy: .whitespaces)
        for i in 0..<words.count {
            if let minutes = Int(words[i]) {
                if i + 1 < words.count {
                    let nextWord = words[i + 1].lowercased()
                    if nextWord.contains("minute") || nextWord.contains("min") {
                        timerSeconds = minutes * 60
                        timerRemaining = timerSeconds
                        timerName = "\(minutes) minute timer"
                        startTimer()
                        return
                    }
                }
            }
        }
        
        // Default timer if no time found
        timerSeconds = 30
        timerRemaining = 30
        timerName = "30 second timer"
        startTimer()
    }
    
    /// Start the timer countdown
    func startTimer() {
        stopTimer()
        isTimerRunning = true
        
        timerID = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timerRemaining > 0 {
                timerRemaining -= 1
                print("⏰ Timer: \(timerRemaining) seconds remaining")
            } else {
                // Timer finished
                stopTimer()
                showingTimerAlert = true
                playTimerSound()
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
    
    /// Stop the timer
    func stopTimer() {
        timerID?.invalidate()
        timerID = nil
        isTimerRunning = false
    }
    
    // MARK: - Sound Helper Functions
    
    /// Play sound and vibrate when timer finishes
    func playTimerSound() {
        // System alert sound
        let systemSoundID: SystemSoundID = 1005
        AudioServicesPlaySystemSound(systemSoundID)
        // Vibrate on iPhone
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    // MARK: - Cookbook Helper Functions
    
    /// Save cooked meal to cookbook - Local storage only (works for all users)
    func saveToCookbook(meal: Meal) {
        print("📝 Saving to cookbook: \(meal.strMeal)")
        
        // 1. Load existing cookbook from UserDefaults
        var cookbook: [CookedMeal] = []
        if let data = UserDefaults.standard.data(forKey: "cookbook"),
           let saved = try? JSONDecoder().decode([CookedMeal].self, from: data) {
            cookbook = saved
            print("📚 Loaded \(cookbook.count) existing meals")
        } else {
            print("📚 No existing cookbook found, creating new one")
        }
        
        // 2. Check if meal already exists
        let exists = cookbook.contains { $0.id == meal.idMeal }
        
        if !exists {
            // 3. Create new CookedMeal with empty rating and notes
            let cookedMeal = CookedMeal(
                id: meal.idMeal,
                name: meal.strMeal,
                dateCooked: Date(),
                date: Date().formatted(date: .abbreviated, time: .omitted),
                rating: nil,
                notes: nil
            )
            
            // 4. Add to cookbook
            cookbook.append(cookedMeal)
            print("✅ Added meal: \(meal.strMeal)")
            
            // 5. Save back to UserDefaults
            do {
                let data = try JSONEncoder().encode(cookbook)
                UserDefaults.standard.set(data, forKey: "cookbook")
                print("💾 Saved \(cookbook.count) meals to cookbook")
                
                // Post notification to refresh CookbookView
                NotificationCenter.default.post(
                    name: NSNotification.Name("CookbookUpdated"),
                    object: nil
                )
                
                // Verify save worked
                if let verifyData = UserDefaults.standard.data(forKey: "cookbook"),
                   let verifyMeals = try? JSONDecoder().decode([CookedMeal].self, from: verifyData) {
                    print("✅ Verified: \(verifyMeals.count) meals in cookbook")
                }
            } catch {
                print("❌ Error saving cookbook: \(error)")
            }
        } else {
            print("ℹ️ Meal already in cookbook: \(meal.strMeal)")
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CookModeView(meal: Meal.previewMeal)
    }
}
