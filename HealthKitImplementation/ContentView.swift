//
//  ContentView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 15/8/25.
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView(healthKitManager: healthKitManager)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .tag(0)
            
            // Activity Tab
            ActivityView(healthKitManager: healthKitManager)
                .tabItem {
                    Image(systemName: "figure.walk")
                    Text("Activity")
                }
                .tag(1)
            
            // Goals Tab
            GoalsView(healthKitManager: healthKitManager)
                .tabItem {
                    Image(systemName: "target")
                    Text("Goals")
                }
                .tag(2)
            
            // Profile Tab
            ProfileView(healthKitManager: healthKitManager)
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
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
                        Button(action: {
                            healthKitManager.fetchTodaysData()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Authorization Request Notification
                    if healthKitManager.needsAuthorization {
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
                    
                    // Error Message (only for actual errors)
                    if let errorMessage = healthKitManager.errorMessage, !healthKitManager.needsAuthorization {
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
                                healthKitManager.refreshAuthorizationStatus()
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
                    
                    // Main Content (only show when authorized)
                    if healthKitManager.isAuthorized {
                        // Main Metrics Cards
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
                        
                        // Weekly Steps Chart
                        WeeklyStepsChart(healthKitManager: healthKitManager)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Fitness Tracker")
            .refreshable {
                healthKitManager.fetchTodaysData()
                healthKitManager.fetchWeeklySteps()
            }
        }
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ProgressView(value: min(progress, 1.0))
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(y: 0.5)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Weekly Steps Chart
struct WeeklyStepsChart: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Steps")
                .font(.headline)
                .fontWeight(.semibold)
            
            if healthKitManager.weeklySteps.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay(
                        VStack {
                            ProgressView()
                            Text("Loading chart data...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    )
            } else {
                Chart(healthKitManager.weeklySteps) { step in
                    BarMark(
                        x: .value("Day", step.day),
                        y: .value("Steps", step.steps)
                    )
                    .foregroundStyle(.blue.gradient)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    ContentView()
}
