//
//  HealthStatsSection.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI

// MARK: - Health Stats Section
struct HealthStatsSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Stats")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                HealthStatCard(
                    title: "Weight",
                    value: String(format: "%.1f kg", healthKitManager.userWeight),
                    icon: "scalemass.fill",
                    color: .blue
                )
                
                HealthStatCard(
                    title: "Height",
                    value: String(format: "%.0f cm", healthKitManager.userHeight),
                    icon: "ruler.fill",
                    color: .green
                )
                
                HealthStatCard(
                    title: "BMI",
                    value: String(format: "%.1f", calculateBMI()),
                    icon: "heart.circle.fill",
                    color: getBMIColor()
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func calculateBMI() -> Double {
        let heightInMeters = healthKitManager.userHeight / 100
        guard heightInMeters > 0 else { return 0 }
        return healthKitManager.userWeight / (heightInMeters * heightInMeters)
    }
    
    private func getBMIColor() -> Color {
        let bmi = calculateBMI()
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
}
