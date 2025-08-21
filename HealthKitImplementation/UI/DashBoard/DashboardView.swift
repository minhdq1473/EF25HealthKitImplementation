//
//  DashBoardView.swift
//  HealthKitImplementation
//
//  Created by Admin on 20/8/25.
//

import Foundation
import SwiftUI

struct DashboardView: View {
    @ObservedObject var healthKitManager: HealthKitManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView(healthKitManager: healthKitManager)
                    
                    if healthKitManager.needsAuthorization {
                        AuthorizationRequestView(healthKitManager: healthKitManager)
                    }
                    
                    if let errorMessage = healthKitManager.errorMessage, !healthKitManager.needsAuthorization {
                        ErrorMessageView(errorMessage: errorMessage, healthKitManager: healthKitManager)
                    }
                    
                    if healthKitManager.isAuthorized {
                        MetricsGridView(healthKitManager: healthKitManager)
                        
                        WeeklyStepsChart(healthKitManager: healthKitManager)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Fitness Tracker")
            .refreshable {
                healthKitManager.fetchTodaysData()
                healthKitManager.fetchWeeklySteps()
            }
        }
    }
}

