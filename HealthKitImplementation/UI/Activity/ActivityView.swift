//
//  ActivityView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 15/8/25.
//

import SwiftUI
import Charts

struct ActivityView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
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

// MARK: - Achievement Models and Views
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isUnlocked: Bool
}
//#Preview {
//    ActivityView(healthKitManager: HealthKitManager())
//}
