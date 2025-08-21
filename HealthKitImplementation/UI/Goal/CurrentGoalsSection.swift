//
//  CurrentGoalsSection.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI
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
