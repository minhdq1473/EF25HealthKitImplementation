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

// MARK: - Profile Header Section
struct ProfileHeaderSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    private var genderString: String {
        switch healthKitManager.userGender {
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        default: return "Not specified"
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Profile Image Placeholder
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.blue, .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 100, height: 100)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 8) {
                Text("User Profile")
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 16) {
                    ProfileInfoPill(
                        icon: "person.fill",
                        text: genderString
                    )
                    
                    ProfileInfoPill(
                        icon: "calendar",
                        text: "\(healthKitManager.userAge) years"
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}

// MARK: - Profile Info Pill
struct ProfileInfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Health Stats Section
struct HealthStatsSection: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Health Stats")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                HealthStatCard(
                    title: "Weight",
                    value: String(format: "%.1f kg", healthKitManager.userWeight),
                    icon: "scalemass.fill",
                    color: .blue
                )
                
                HealthStatCard(
                    title: "Height",
                    value: String(format: "%.0f cm", healthKitManager.userHeight),
                    icon: "ruler.fill",
                    color: .green
                )
                
                HealthStatCard(
                    title: "BMI",
                    value: String(format: "%.1f", calculateBMI()),
                    icon: "heart.circle.fill",
                    color: getBMIColor()
                )
                
                HealthStatCard(
                    title: "Age",
                    value: "\(healthKitManager.userAge) years",
                    icon: "calendar.circle.fill",
                    color: .purple
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func calculateBMI() -> Double {
        let heightInMeters = healthKitManager.userHeight / 100
        guard heightInMeters > 0 else { return 0 }
        return healthKitManager.userWeight / (heightInMeters * heightInMeters)
    }
    
    private func getBMIColor() -> Color {
        let bmi = calculateBMI()
        switch bmi {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
}

// MARK: - Health Stat Card
struct HealthStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

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

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

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

// MARK: - App Info Row
struct AppInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: Double
    @State private var height: Double
    @State private var age: Int
    @State private var gender: HKBiologicalSex
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        self._weight = State(initialValue: healthKitManager.userWeight)
        self._height = State(initialValue: healthKitManager.userHeight)
        self._age = State(initialValue: healthKitManager.userAge)
        self._gender = State(initialValue: healthKitManager.userGender)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    HStack {
                        Text("Weight (kg)")
                        Spacer()
                        TextField("Weight", value: $weight, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Height (cm)")
                        Spacer()
                        TextField("Height", value: $height, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("Age", value: $age, format: .number)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    
                    Picker("Gender", selection: $gender) {
                        Text("Not specified").tag(HKBiologicalSex.notSet)
                        Text("Female").tag(HKBiologicalSex.female)
                        Text("Male").tag(HKBiologicalSex.male)
                        Text("Other").tag(HKBiologicalSex.other)
                    }
                }
                
                Section {
                    Button("Reset to HealthKit Data") {
                        // Reset to HealthKit values
                        weight = healthKitManager.userWeight
                        height = healthKitManager.userHeight
                        age = healthKitManager.userAge
                        gender = healthKitManager.userGender
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveProfile() {
        // Use the new sync method to update both app and Health app
        healthKitManager.updateUserProfile(
            weight: weight,
            height: height,
            age: age,
            gender: gender
        )
    }
}

#Preview {
    ProfileView(healthKitManager: HealthKitManager())
}
