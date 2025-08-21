//
//  WeeklyStepsChart.swift
//  HealthKitImplementation
//
//  Created by Admin on 20/8/25.
//

import SwiftUI
import Charts

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
