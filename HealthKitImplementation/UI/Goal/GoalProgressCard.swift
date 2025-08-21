//
//  GoalProgressCard.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI
// MARK: - Goal Progress Card
struct GoalProgressCard: View {
    let title: String
    let current: Double
    let goal: Double
    let unit: String
    let icon: String
    let color: Color
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(current / goal, 1.0)
    }
    
    private var isGoalMet: Bool {
        current >= goal
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
                if isGoalMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                VStack(spacing: 2) {
                    Text(String(format: "%.0f", current))
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("of \(String(format: "%.0f", goal))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 100)
            
            // Footer
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(String(format: "%.0f%%", progress * 100)) complete")
                    .font(.caption)
                    .foregroundColor(isGoalMet ? .green : .secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}
