//
//  AuthorizationRequestView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import SwiftUI

struct AuthorizationRequestView: View {
    let healthKitManager: HealthKitManager
    
    var body: some View {
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
}
