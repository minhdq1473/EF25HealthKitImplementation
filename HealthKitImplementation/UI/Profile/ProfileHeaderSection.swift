//
//  ProfileHeaderSection.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import Foundation
import SwiftUI

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
                
                ProfileInfoPill(
                    icon: "person.fill",
                    text: genderString
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .padding(.horizontal)
    }
}
