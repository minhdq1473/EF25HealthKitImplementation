//
//  MetricsGridView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import SwiftUI

struct MetricsGridView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            MetricCard(
                title: "Steps",
                value: "\(healthKitManager.stepCount)",
                subtitle: "steps",
                icon: "figure.walk",
                color: .blue,
                progress: healthKitManager.getStepGoalProgress()
            )
            
            MetricCard(
                title: "Calories",
                value: String(format: "%.0f", healthKitManager.caloriesBurned),
                subtitle: "kcal",
                icon: "flame.fill",
                color: .orange,
                progress: healthKitManager.getCalorieGoalProgress()
            )
            
            MetricCard(
                title: "Distance",
                value: String(format: "%.2f", healthKitManager.distance),
                subtitle: "km",
                icon: "location.circle.fill",
                color: .green,
                progress: healthKitManager.distance / 10.0 // 10km goal
            )
            
            MetricCard(
                title: "Active Time",
                value: String(format: "%.0f", healthKitManager.caloriesBurned / 8), // Rough estimate
                subtitle: "minutes",
                icon: "timer",
                color: .purple,
                progress: (healthKitManager.caloriesBurned / 8) / 60.0 // 60 min goal
            )
        }
        .padding(.horizontal)
    }
}
