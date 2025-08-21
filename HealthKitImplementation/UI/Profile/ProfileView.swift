//
//  ProfileView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 15/8/25.
//

import SwiftUI
import HealthKit

struct ProfileView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    ProfileHeaderSection(healthKitManager: healthKitManager)
                    
                    // Health Stats
                    HealthStatsSection(healthKitManager: healthKitManager)
                    
                    // Settings
                    SettingsSection(showingEditProfile: $showingEditProfile)
                    
                    // App Info
                    AppInfoSection()
                }
                .padding(.vertical)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                }
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(healthKitManager: healthKitManager)
            }
        }
    }
}

#Preview {
    ProfileView(healthKitManager: HealthKitManager())
}
