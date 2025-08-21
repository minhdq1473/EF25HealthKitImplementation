//
//  HeaderView.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 21/8/25.
//

import SwiftUI

struct HeaderView: View {
    let healthKitManager: HealthKitManager
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Today's Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: {
                healthKitManager.fetchTodaysData()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
    }
}
