//
//  EditProfileView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI
import HealthKit

// MARK: - Edit Profile View
struct EditProfileView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var weight: Double
    @State private var height: Double
    @State private var gender: HKBiologicalSex
    
    init(healthKitManager: HealthKitManager) {
        self.healthKitManager = healthKitManager
        self._weight = State(initialValue: healthKitManager.userWeight)
        self._height = State(initialValue: healthKitManager.userHeight)
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
            gender: gender
        )
    }
}
