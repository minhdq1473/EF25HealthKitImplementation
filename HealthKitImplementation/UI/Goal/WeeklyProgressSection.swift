//
//  WeeklyProgressSection.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI
// MARK: - Weekly Progress Section
struct WeeklyProgressSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var weeklyAverage: Int {
        guard !healthKitManager.weeklySteps.isEmpty else { return 0 }
        let total = healthKitManager.weeklySteps.reduce(0) { $0 + $1.steps }
        return total / healthKitManager.weeklySteps.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Overview")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Daily Average")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(weeklyAverage) steps")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("This Week")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(healthKitManager.weeklySteps.reduce(0) { $0 + $1.steps }) steps")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                
                if !healthKitManager.weeklySteps.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(healthKitManager.weeklySteps) { step in
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(.blue)
                                    .frame(width: 20, height: CGFloat(step.steps) / 500.0) // Scale for display
                                    .cornerRadius(2)
                                Text(step.day.prefix(1))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 60)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

// MARK: - Goal Suggestions Section
struct GoalSuggestionsSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @Binding var stepGoal: Double
    @Binding var calorieGoal: Double
    
    var suggestions: [GoalSuggestion] {
        var list: [GoalSuggestion] = []
        
        // Step suggestions
        if healthKitManager.stepCount > Int(stepGoal) {
            let newGoal = stepGoal + 1000
            list.append(GoalSuggestion(
                title: "Increase Step Goal",
                description: "You're crushing your current goal! Try \(String(format: "%.0f", newGoal)) steps.",
                currentValue: stepGoal,
                suggestedValue: newGoal,
                type: .steps
            ))
        }
        
        // Calorie suggestions
        if healthKitManager.caloriesBurned > calorieGoal {
            let newGoal = calorieGoal + 50
            list.append(GoalSuggestion(
                title: "Boost Calorie Goal",
                description: "You're burning more than expected! Try \(String(format: "%.0f", newGoal)) calories.",
                currentValue: calorieGoal,
                suggestedValue: newGoal,
                type: .calories
            ))
        }
        
        return list
    }
    
    var body: some View {
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("Goal Suggestions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                ForEach(suggestions) { suggestion in
                    GoalSuggestionCard(suggestion: suggestion) {
                        switch suggestion.type {
                        case .steps:
                            stepGoal = suggestion.suggestedValue
                        case .calories:
                            calorieGoal = suggestion.suggestedValue
                        default:
                            break
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Goal Suggestion Models and Views
struct GoalSuggestion: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let currentValue: Double
    let suggestedValue: Double
    let type: GoalsView.GoalType
}

struct GoalSuggestionCard: View {
    let suggestion: GoalSuggestion
    let onAccept: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: suggestion.type.icon)
                .font(.title2)
                .foregroundColor(suggestion.type.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(suggestion.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Accept") {
                onAccept()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Goal Editor View
struct GoalEditorView: View {
    @Binding var stepGoal: Double
    @Binding var calorieGoal: Double
    @Binding var distanceGoal: Double
    @Binding var activeMinutesGoal: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Daily Goals") {
                    HStack {
                        Image(systemName: "figure.walk")
                            .foregroundColor(.blue)
                        Text("Steps")
                        Spacer()
                        TextField("Steps", value: $stepGoal, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("Calories")
                        Spacer()
                        TextField("Calories", value: $calorieGoal, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    
                    HStack {
                        Image(systemName: "location.circle.fill")
                            .foregroundColor(.green)
                        Text("Distance (km)")
                        Spacer()
                        TextField("Distance", value: $distanceGoal, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.purple)
                        Text("Active Minutes")
                        Spacer()
                        TextField("Minutes", value: $activeMinutesGoal, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                }
            }
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
