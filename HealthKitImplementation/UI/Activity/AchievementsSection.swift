//
//  AchievementsSection.swift
//  HealthKitImplementation
//
//  Created by Admin on 23/8/25.
//

import Foundation
import SwiftUI

// MARK: - Achievements Section
struct AchievementsSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var achievements: [Achievement] {
        var list: [Achievement] = []
        
        // Step achievements
        if healthKitManager.stepCount >= 10000 {
            list.append(Achievement(title: "10K Steps", description: "Completed daily step goal", icon: "figure.walk", color: .blue, isUnlocked: true))
        }
        if healthKitManager.stepCount >= 15000 {
            list.append(Achievement(title: "Step Master", description: "Walked 15,000 steps in a day", icon: "star.fill", color: .yellow, isUnlocked: true))
        }
        
        // Calorie achievements
        if healthKitManager.caloriesBurned >= 400 {
            list.append(Achievement(title: "Calorie Burner", description: "Burned 400+ calories", icon: "flame.fill", color: .orange, isUnlocked: true))
        }
        
        // Distance achievements
        if healthKitManager.distance >= 5.0 {
            list.append(Achievement(title: "5K Walker", description: "Walked 5 kilometers", icon: "location.circle.fill", color: .green, isUnlocked: true))
        }
        
        // Add locked achievements
        if healthKitManager.stepCount < 20000 {
            list.append(Achievement(title: "Marathon Walker", description: "Walk 20,000 steps in a day", icon: "figure.run", color: .gray, isUnlocked: false))
        }
        if healthKitManager.caloriesBurned < 600 {
            list.append(Achievement(title: "Calorie Champion", description: "Burn 600+ calories", icon: "trophy.fill", color: .gray, isUnlocked: false))
        }
        
        return list
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(achievements) { achievement in
                    AchievementCard(achievement: achievement)
                }
            }
            .padding(.horizontal)
        }
    }
}

