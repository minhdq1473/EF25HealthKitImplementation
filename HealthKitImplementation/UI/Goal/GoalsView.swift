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

#Preview {
    GoalsView(healthKitManager: HealthKitManager())
}
