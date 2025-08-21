//
//  ActivitySummarySection.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI
// MARK: - Activity Summary Section
struct ActivitySummarySection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Summary")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ActivitySummaryCard(
                        title: "Steps",
                        value: "\(healthKitManager.stepCount)",
                        subtitle: "of 10,000 goal",
                        icon: "figure.walk",
                        color: .blue,
                        progress: healthKitManager.getStepGoalProgress()
                    )
                    
                    ActivitySummaryCard(
                        title: "Calories",
                        value: String(format: "%.0f", healthKitManager.caloriesBurned),
                        subtitle: "of 400 goal",
                        icon: "flame.fill",
                        color: .orange,
                        progress: healthKitManager.getCalorieGoalProgress()
                    )
                    
                    ActivitySummaryCard(
                        title: "Distance",
                        value: String(format: "%.2f km", healthKitManager.distance),
                        subtitle: "walking/running",
                        icon: "location.circle.fill",
                        color: .green,
                        progress: healthKitManager.distance / 10.0
                    )
                    
                    ActivitySummaryCard(
                        title: "Active Minutes",
                        value: String(format: "%.0f", healthKitManager.caloriesBurned / 8),
                        subtitle: "estimated",
                        icon: "timer",
                        color: .purple,
                        progress: (healthKitManager.caloriesBurned / 8) / 60.0
                    )
                }
                .padding(.horizontal)
            }
        }
    }
}
