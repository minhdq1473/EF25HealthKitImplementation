//
//  GoalsView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 15/8/25.
//

import SwiftUI

struct GoalsView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var stepGoal: Double = 10000
    @State private var calorieGoal: Double = 400
    @State private var distanceGoal: Double = 10
    @State private var activeMinutesGoal: Double = 60
    @State private var showingGoalEditor = false
    @State private var selectedGoalType: GoalType = .steps
    
    enum GoalType: String, CaseIterable {
        case steps = "Steps"
        case calories = "Calories"
        case distance = "Distance"
        case activeMinutes = "Active Minutes"
        
        var icon: String {
            switch self {
            case .steps: return "figure.walk"
            case .calories: return "flame.fill"
            case .distance: return "location.circle.fill"
            case .activeMinutes: return "timer"
            }
        }
        
        var color: Color {
            switch self {
            case .steps: return .blue
            case .calories: return .orange
            case .distance: return .green
            case .activeMinutes: return .purple
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Goals Overview
                    CurrentGoalsSection(
                        healthKitManager: healthKitManager,
                        stepGoal: stepGoal,
                        calorieGoal: calorieGoal,
                        distanceGoal: distanceGoal,
                        activeMinutesGoal: activeMinutesGoal
                    )
                    
                    // Goal Progress Details
                    GoalProgressSection(
                        healthKitManager: healthKitManager,
                        stepGoal: stepGoal,
                        calorieGoal: calorieGoal,
                        distanceGoal: distanceGoal,
                        activeMinutesGoal: activeMinutesGoal
                    )
                    
                    // Weekly Progress
                    WeeklyProgressSection(healthKitManager: healthKitManager)
                    
                    // Goal Suggestions
                    GoalSuggestionsSection(
                        healthKitManager: healthKitManager,
                        stepGoal: $stepGoal,
                        calorieGoal: $calorieGoal
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Goals")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingGoalEditor = true
                    }
                }
            }
            .sheet(isPresented: $showingGoalEditor) {
                GoalEditorView(
                    stepGoal: $stepGoal,
                    calorieGoal: $calorieGoal,
                    distanceGoal: $distanceGoal,
                    activeMinutesGoal: $activeMinutesGoal
                )
            }
        }
    }
}

// MARK: - Current Goals Section
struct CurrentGoalsSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    let stepGoal: Double
    let calorieGoal: Double
    let distanceGoal: Double
    let activeMinutesGoal: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                GoalProgressCard(
                    title: "Steps",
                    current: Double(healthKitManager.stepCount),
                    goal: stepGoal,
                    unit: "",
                    icon: "figure.walk",
                    color: .blue
                )
                
                GoalProgressCard(
                    title: "Calories",
                    current: healthKitManager.caloriesBurned,
                    goal: calorieGoal,
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange
                )
                
                GoalProgressCard(
                    title: "Distance",
                    current: healthKitManager.distance,
                    goal: distanceGoal,
                    unit: "km",
                    icon: "location.circle.fill",
                    color: .green
                )
                
                GoalProgressCard(
                    title: "Active Minutes",
                    current: healthKitManager.caloriesBurned / 8, // Rough estimate
                    goal: activeMinutesGoal,
                    unit: "min",
                    icon: "timer",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Goal Progress Card
struct GoalProgressCard: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let icon: String
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }
    
    private var isGoalMet: Bool {
        current >= goal
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
                if isGoalMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                VStack(spacing: 2) {
                    Text(String(format: "%.0f", current))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("of \(String(format: "%.0f", goal))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 100)
            
            // Footer
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(String(format: "%.0f%%", progress * 100)) complete")
                    .font(.caption)
                    .foregroundColor(isGoalMet ? .green : .secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Goal Progress Section
struct GoalProgressSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    let stepGoal: Double
    let calorieGoal: Double
    let distanceGoal: Double
    let activeMinutesGoal: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Progress")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                GoalProgressRow(
                    title: "Steps",
                    current: Double(healthKitManager.stepCount),
                    goal: stepGoal,
                    unit: "steps",
                    icon: "figure.walk",
                    color: .blue
                )
                
                GoalProgressRow(
                    title: "Calories",
                    current: healthKitManager.caloriesBurned,
                    goal: calorieGoal,
                    unit: "kcal",
                    icon: "flame.fill",
                    color: .orange
                )
                
                GoalProgressRow(
                    title: "Distance",
                    current: healthKitManager.distance,
                    goal: distanceGoal,
                    unit: "km",
                    icon: "location.circle.fill",
                    color: .green
                )
                
                GoalProgressRow(
                    title: "Active Minutes",
                    current: healthKitManager.caloriesBurned / 8,
                    goal: activeMinutesGoal,
                    unit: "min",
                    icon: "timer",
                    color: .purple
                )
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

// MARK: - Goal Progress Row
struct GoalProgressRow: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let icon: String
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(String(format: "%.0f", current))/\(String(format: "%.0f", goal)) \(unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(y: 1.5)
            }
        }
    }
}

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

#Preview {
    GoalsView(healthKitManager: HealthKitManager())
}
