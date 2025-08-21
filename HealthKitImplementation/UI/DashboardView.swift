//
//  DashBoardView.swift
//  HealthKitImplementation
//
//  Created by Admin on 20/8/25.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView()
                    
                    if healthKitManager.needsAuthorization {
                        AuthorizationRequestView(healthKitManager: healthKitManager)
                    }
                    
                    if let errorMessage = healthKitManager.errorMessage, !healthKitManager.needsAuthorization {
                        ErrorMessageView(errorMessage: errorMessage, healthKitManager: healthKitManager)
                    }
                    
                    if healthKitManager.isAuthorized {
                        MetricsGridView(healthKitManager: healthKitManager)
                        
                        WeeklyStepsChart(healthKitManager: healthKitManager)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Fitness Tracker")
            .refreshable {
//                healthKitManager.fetchTodaysData()
                healthKitManager.fetchWeeklySteps()
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Today's Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
//            Button(action: {
////                healthKitManager.fetchTodaysData()
//            }) {
//                Image(systemName: "arrow.clockwise")
//                    .font(.title2)
//                    .foregroundColor(.blue)
//            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Authorization Request View
struct AuthorizationRequestView: View {
    let healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Connect to Health")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("To track your fitness activity, we need access to your Health data. This helps us provide accurate step counts and calorie calculations.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                healthKitManager.requestAuthorization()
            }) {
                HStack {
                    Image(systemName: "heart.fill")
                    Text("Connect to Health")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Error Message View
struct ErrorMessageView: View {
    let errorMessage: String
    let healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Health Access Issue")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(errorMessage)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.horizontal)
            
            Button(action: {
//                healthKitManager.refreshAuthorizationStatus()
            }) {
                Text("Refresh Status")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Metrics Grid View
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
