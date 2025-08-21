//
//  ErrorMessageView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import SwiftUI

// MARK: - Error Message View
struct ErrorMessageView: View {
    let errorMessage: String
    let healthKitManager: HealthKitManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Health Access Issue")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(errorMessage)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.horizontal)
            
            Button(action: {
                healthKitManager.refreshAuthorizationStatus()
            }) {
                Text("Refresh Status")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
