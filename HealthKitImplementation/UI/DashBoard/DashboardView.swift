//
//  DashBoardView.swift
//  HealthKitImplementation
//
//  Created by Admin on 20/8/25.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var healthKitManager: HealthKitManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView(healthKitManager: healthKitManager)
                    
                    if healthKitManager.needsAuthorization {
                        AuthorizationRequestView(healthKitManager: healthKitManager)
                    } else if healthKitManager.errorMessage == nil {
                        MetricsGridView(healthKitManager: healthKitManager)
                        
                        WeeklyStepsChart(healthKitManager: healthKitManager)
                            .padding(.horizontal)
                    }

                    
                    if let errorMessage = healthKitManager.errorMessage {
                        ErrorMessageView(errorMessage: errorMessage, healthKitManager: healthKitManager)
                    }
                    
                }
                .padding(.vertical)
            }
            .navigationTitle("Fitness Tracker")
        }
    }
}

