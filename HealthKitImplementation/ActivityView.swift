//
//  ActivityView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 15/8/25.
//

import SwiftUI
import Charts

struct ActivityView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var selectedTimeRange = TimeRange.week
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Activity Summary Cards
                    ActivitySummarySection(healthKitManager: healthKitManager)
                    
                    // Detailed Charts Section
                    ActivityChartsSection(healthKitManager: healthKitManager, timeRange: selectedTimeRange)
                    
                    // Activity Achievements
                    AchievementsSection(healthKitManager: healthKitManager)
                }
                .padding(.vertical)
            }
            .navigationTitle("Activity")
            .refreshable {
//                healthKitManager.fetchTodaysData()
                healthKitManager.fetchWeeklySteps()
            }
        }
    }
}

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

// MARK: - Activity Summary Card
struct ActivitySummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 16) {
            // Header with icon
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
                Text(String(format: "%.0f%%", min(progress * 100, 100)))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: 80, height: 80)
            
            // Footer
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: 160)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Activity Charts Section
struct ActivityChartsSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    let timeRange: ActivityView.TimeRange
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activity Trends")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            // Steps Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Steps")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                if !healthKitManager.weeklySteps.isEmpty {
                    Chart(healthKitManager.weeklySteps) { step in
                        LineMark(
                            x: .value("Day", step.day),
                            y: .       value("Steps", step.steps)
                        )
                        .foregroundStyle(.blue)
                        .symbol(.circle)
                        
                        AreaMark(
                            x: .value("Day", step.day),
                            y: .value("Steps", step.steps)
                        )
                        .foregroundStyle(.blue.opacity(0.2))
                    }
                    .frame(height: 150)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                    .padding(.horizontal)
                } else {
                    Rectangle()
                        .fill(Color(.systemGray6))
                        .frame(height: 150)
                        .overlay(
                            Text("Loading...")
                                .foregroundColor(.secondary)
                        )
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

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

// MARK: - Achievement Models and Views
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
            
            VStack(spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            } else {
                Image(systemName: "lock.circle.fill")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .opacity(achievement.isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    ActivityView(healthKitManager: HealthKitManager())
}
