//
//  ActivityChartsSection.swift
//  HealthKitImplementation
//
//  Created by Admin on 23/8/25.
//

import Foundation
import SwiftUI
import Charts
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

