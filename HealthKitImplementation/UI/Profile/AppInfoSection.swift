//
//  AppInfoSection.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI

// MARK: - App Info Section
struct AppInfoSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                AppInfoRow(title: "Version", value: "1.0.0")
                AppInfoRow(title: "Build", value: "1")
                AppInfoRow(title: "HealthKit", value: "Enabled")
                
                Divider()
                
                VStack(spacing: 8) {
                    Text("Fitness Tracker")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Track your daily activity, set goals, and stay motivated on your fitness journey.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}

