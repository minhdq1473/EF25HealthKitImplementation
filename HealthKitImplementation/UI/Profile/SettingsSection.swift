//
//  SettingsSection.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI

// MARK: - Settings Section
struct SettingsSection: View {
    @Binding var showingEditProfile: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "person.circle",
                    title: "Edit Profile",
                    subtitle: "Update your personal information",
                    color: .blue
                ) {
                    showingEditProfile = true
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "heart.circle",
                    title: "Health Permissions",
                    subtitle: "Manage HealthKit access",
                    color: .red
                ) {
                    if let url = URL(string: "x-apple-health://") {
                        UIApplication.shared.open(url)
                    }
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "bell.circle",
                    title: "Notifications",
                    subtitle: "Goal reminders and achievements",
                    color: .orange
                ) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                
                Divider()
                    .padding(.leading, 50)
                
                SettingsRow(
                    icon: "chart.bar.circle",
                    title: "Data Export",
                    subtitle: "Export your fitness data",
                    color: .purple
                ) {
                    // Handle data export
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        }
    }
}
