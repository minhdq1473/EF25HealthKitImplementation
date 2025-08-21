//
//  GoalProgressSection.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI

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
