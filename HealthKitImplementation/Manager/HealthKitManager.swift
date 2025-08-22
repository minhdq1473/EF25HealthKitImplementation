//
//  HealthKitManager.swift
//  HealthKitImplementation
//
//  Created by iKame Elite Fresher 2025 on 15/8/25.
//

import Foundation
import HealthKit
import SwiftUI

class HealthKitManager: ObservableObject {
    private var healthStore = HKHealthStore()
    private var activeObserverQueries: [HKObserverQuery] = []
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var stepCount: Int = 0
    @Published var caloriesBurned: Double = 0
    @Published var distance: Double = 0
    @Published var weeklySteps: [DailyStep] = []
    @Published var isFetching: Bool = false
    @Published var isAuthorized = false
    @Published var needsAuthorization = false
    @Published var errorMessage: String?
    
    // User profile for calorie calculation
    @Published var userWeight: Double = 0 // kg
    @Published var userHeight: Double = 0// cm
    @Published var userGender: HKBiologicalSex = .notSet
    
    // UserDefaults keys for persistent storage
    private let authorizationKey = "HealthKitAuthorized"
    private let authorizationGrantedKey = "HealthKitAuthorizationGranted"
    private let anchorKeySteps = "HKAnchor_StepCount"
    private let anchorKeyDistance = "HKAnchor_DistanceWalkingRunning"
    private let anchorKeyWeight = "HKAnchor_BodyMass"
    private let anchorKeyHeight = "HKAnchor_Height"
    
    static let shared = HealthKitManager()
    init() {
        loadPersistedAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func loadPersistedAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.errorMessage = "HealthKit is not available on this device"
                self.isAuthorized = false
                self.needsAuthorization = false
            }
            return
        }
        
        // Load persisted authorization status
        let hasAttemptedAuth = UserDefaults.standard.bool(forKey: authorizationKey)
        let wasGranted = UserDefaults.standard.bool(forKey: authorizationGrantedKey)
        
        DispatchQueue.main.async {
            if wasGranted {
                // User previously granted authorization
                self.isAuthorized = true
                self.needsAuthorization = false
                self.errorMessage = nil
                print("Loading with persisted authorization: granted")
                DispatchQueue.global().async {
                    self.loadUserProfile()
                    self.fetchTodaysData()
                    self.fetchWeeklySteps()
                    self.startObservingHealthKitChanges()
                }
            } else if hasAttemptedAuth {
                // User was asked before but didn't grant or denied
                self.isAuthorized = false
                self.needsAuthorization = false
                self.errorMessage = "Health access is required. Please enable in Settings > Privacy & Security > Health."
                print("Loading with persisted authorization: denied/not granted")
            } else {
                // First time user - show authorization request
                self.isAuthorized = false
                self.needsAuthorization = true
                self.errorMessage = nil
                print("Loading as first-time user - will show authorization request")
            }
        }
    }
    // Refresh authorization status (manual check only)
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            DispatchQueue.main.async {
                self.errorMessage = "HealthKit is not available on this device"
            }
            return
        }
        
        // Define types to read
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!
        ]
        
        // Types to write for syncing data back to Health app
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!
        ]
        
        print("Requesting HealthKit authorization...")
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            print("HealthKit authorization result: success=\(success), error=\(String(describing: error))")
            
            DispatchQueue.main.async {
                // Mark that we've attempted authorization
                UserDefaults.standard.set(true, forKey: self?.authorizationKey ?? "")
                
                if success {
                    print("HealthKit authorization granted")
                    // Save the granted status
                    UserDefaults.standard.set(true, forKey: self?.authorizationGrantedKey ?? "")
                    self?.isAuthorized = true
                    self?.needsAuthorization = false
                    self?.errorMessage = nil
                    
                    // Load data on background thread
                    DispatchQueue.global(qos: .userInitiated).async {
                        self?.loadUserProfile()
                        self?.fetchTodaysData()
                        self?.fetchWeeklySteps()
                        self?.startObservingHealthKitChanges()
                    }
                } else {
                    let errorMsg = error?.localizedDescription ?? "Authorization failed. Please enable Health access in Settings."
                    print("HealthKit authorization failed: \(errorMsg)")
                    // Save the denied status
                    UserDefaults.standard.set(false, forKey: self?.authorizationGrantedKey ?? "")
                    self?.errorMessage = errorMsg
                    self?.isAuthorized = false
                    self?.needsAuthorization = false
                }
            }
        }
    }
    // MARK: - User Profile
    private func loadUserProfile() {
        print("🔄 Loading user profile...")
        
        // Load user's biological sex
        do {
            let biologicalSex = try healthStore.biologicalSex()
            DispatchQueue.main.async {
                self.userGender = biologicalSex.biologicalSex
                print("✅ Gender loaded: \(biologicalSex.biologicalSex)")
            }
        } catch {
            print("❌ Error loading biological sex: \(error)")
        }
        
        // Load most recent weight
        fetchMostRecentSample(for: .bodyMass) { [weak self] sample in
            if let sample = sample as? HKQuantitySample {
                let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                DispatchQueue.main.async {
                    self?.userWeight = weight
                    print("✅ Weight loaded: \(weight) kg")
                }
            } else {
                print("⚠️ No weight data found")
                DispatchQueue.main.async {
                    self?.userWeight = 0
                }
            }
        }
        
        // Load most recent height
        fetchMostRecentSample(for: .height) { [weak self] sample in
            if let sample = sample as? HKQuantitySample {
                let height = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
                DispatchQueue.main.async {
                    self?.userHeight = height
                    print("✅ Height loaded: \(height) cm")
                }
            } else {
                print("⚠️ No height data found")
                DispatchQueue.main.async {
                    self?.userHeight = 0
                }
            }
        }
    }
    
    private func fetchMostRecentSample(for identifier: HKQuantityTypeIdentifier, completion: @escaping (HKSample?) -> Void) {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: identifier) else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not create most recent sample"
            }
            completion(nil)
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            completion(samples?.first)
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Data Fetching
    func fetchTodaysData() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchStepCount(from: startOfDay, to: endOfDay) { [weak self] steps in
            DispatchQueue.main.async {
                self?.stepCount = steps
                self?.calculateCaloriesFromSteps(steps: steps)
            }
        }
        
        fetchDistance(from: startOfDay, to: endOfDay) { [weak self] distance in
            DispatchQueue.main.async {
                self?.distance = distance
            }
        }
    }
    
    func fetchStepCount() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not create step count"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isFetching = true
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, statistics, error in
            DispatchQueue.main.async {
                self?.isFetching = false
                
                if let error = error {
                    print("Lỗi khi lấy dữ liệu bước chân: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.errorMessage = error.localizedDescription
                    }
                    return
                }
                
                let stepCount = statistics?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                self?.stepCount = Int(stepCount)
            }
        }
        
        healthStore.execute(query)
    }
    func fetchStepCount(from startDate: Date, to endDate: Date, completion: @escaping (Int) -> Void) {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            print("Could not create step count type")
            self.errorMessage = "Could not fetch step count"
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error {
                print("Error fetching step count: \(error.localizedDescription)")
                completion(0)
                DispatchQueue.main.async {
                    self.errorMessage = "Could not fetch step count"
                }
                return
            }
            guard let result = result, let sum = result.sumQuantity() else {
                print("No step data found for period \(startDate) to \(endDate)")
                completion(0)
                DispatchQueue.main.async {
                    self.errorMessage = error?.localizedDescription ?? "Unknown error"
                }
                return
            }
            
            let steps = Int(sum.doubleValue(for: HKUnit.count()))
            print("Fetched \(steps) steps for period")
            completion(steps)
        }
        
        healthStore.execute(query)
    }
    
    func fetchDistance(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            self.errorMessage = "Could not create distance type"
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                if let error = error {
                    print("Error fetching distance: \(error.localizedDescription)")
                }
                completion(0)
                return
            }
            let distance = sum.doubleValue(for: HKUnit.meterUnit(with: .kilo))
            completion(distance)
        }
        
        healthStore.execute(query)
    }
    
    func fetchWeeklySteps() {
        print("🔄 Starting fetchWeeklySteps...")
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        
        print("📅 Fetching steps from \(startDate) to \(endDate)")
        
        var dailySteps: [DailyStep] = []
        let group = DispatchGroup()
        
        for i in 0...6 {
            group.enter()
            let date = calendar.date(byAdding: .day, value: i, to: startDate)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            fetchStepCount(from: startOfDay, to: endOfDay) { steps in
                let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
                let dailyStep = DailyStep(day: dayName, steps: steps, date: date)
                dailySteps.append(dailyStep)
                print("📊 \(dayName): \(steps) steps")
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.weeklySteps = dailySteps.sorted { $0.date < $1.date }
            print("Weekly steps updated: \(self.weeklySteps.count) days")
            for step in self.weeklySteps {
                print("   \(step.day): \(step.steps) steps")
            }
        }
    }
    
    // MARK: - Calorie Calculation
    private func calculateCaloriesFromSteps(steps: Int) {
        // Basic calorie calculation based on steps
        // Formula considers user weight, distance, and metabolic equivalent
        let stepsPerMile = 2000.0 // Average steps per mile
        let miles = Double(steps) / stepsPerMile
        
        // MET (Metabolic Equivalent) for walking varies by speed
        // Assuming moderate walking pace (3.5 mph) = 4.3 METs
        let met = 4.3
        
        // Calories = METs × weight (kg) × time (hours)
        // Estimate time based on average walking speed
        let averageSpeedMph = 3.5
        let timeInHours = miles / averageSpeedMph
        
        let calories = met * userWeight * timeInHours
        
        DispatchQueue.main.async {
            self.caloriesBurned = max(0, calories)
        }
    }
    
    // MARK: - Goals and Achievements
    func getStepGoalProgress() -> Double {
        let dailyGoal = 10000.0 // Default daily goal
        return min(1.0, Double(stepCount) / dailyGoal)
    }
    
    func getCalorieGoalProgress() -> Double {
        let dailyGoal = 400.0 // Default daily calorie goal
        return min(1.0, caloriesBurned / dailyGoal)
    }
    
    // MARK: - Data Sync to Health App
    func updateWeightInHealthApp(weight: Double) {
        guard isAuthorized else { return }
        
        let weightType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        let weightQuantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let weightSample = HKQuantitySample(type: weightType, quantity: weightQuantity, start: Date(), end: Date())
        
        healthStore.save(weightSample) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("Weight updated in Health app: \(weight) kg")
                    self?.userWeight = weight
                } else {
                    print("Failed to update weight in Health app: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    func updateHeightInHealthApp(height: Double) {
        guard isAuthorized else { return }
        
        let heightType = HKQuantityType.quantityType(forIdentifier: .height)!
        let heightQuantity = HKQuantity(unit: HKUnit.meterUnit(with: .centi), doubleValue: height)
        let heightSample = HKQuantitySample(type: heightType, quantity: heightQuantity, start: Date(), end: Date())
        
        healthStore.save(heightSample) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    print("Height updated in Health app: \(height) cm")
                    self?.userHeight = height
                } else {
                    print("Failed to update height in Health app: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // Update user profile and sync to Health app
    func updateUserProfile(weight: Double? = nil, height: Double? = nil, gender: HKBiologicalSex? = nil) {
        if let weight = weight {
            updateWeightInHealthApp(weight: weight)
        }
        
        if let height = height {
            updateHeightInHealthApp(height: height)
        }
        
        if let gender = gender {
            DispatchQueue.main.async {
                self.userGender = gender
            }
        }
    }
    
    // Force refresh user profile data from HealthKit
    func refreshUserProfile() {
        guard isAuthorized else {
            print("❌ Cannot refresh profile - not authorized")
            return
        }
        
        print("🔄 Force refreshing user profile...")
        DispatchQueue.global(qos: .userInitiated).async {
            self.loadUserProfile()
        }
    }

    // MARK: - Live Sync: Observer + Anchored Queries
    private func startObservingHealthKitChanges() {
        guard isAuthorized else { return }

        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
        let heightType = HKObjectType.quantityType(forIdentifier: .height)!

        // Initial anchored fetch to establish anchors and sync UI
        runAnchoredFetch(for: stepType, anchorKey: anchorKeySteps)
        runAnchoredFetch(for: distanceType, anchorKey: anchorKeyDistance)
        runAnchoredFetch(for: weightType, anchorKey: anchorKeyWeight)
        runAnchoredFetch(for: heightType, anchorKey: anchorKeyHeight)

        // Set up observers
        setupObserver(for: stepType, anchorKey: anchorKeySteps)
        setupObserver(for: distanceType, anchorKey: anchorKeyDistance)
        setupObserver(for: weightType, anchorKey: anchorKeyWeight)
        setupObserver(for: heightType, anchorKey: anchorKeyHeight)
    }

    private func stopObservingHealthKitChanges() {
        for query in activeObserverQueries {
            healthStore.stop(query)
        }
        activeObserverQueries.removeAll()
    }

    private func setupObserver(for sampleType: HKSampleType, anchorKey: String) {
        let observer = HKObserverQuery(sampleType: sampleType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer error for \(sampleType): \(error.localizedDescription)")
                completionHandler()
                return
            }

            self?.runAnchoredFetch(for: sampleType, anchorKey: anchorKey) {
                completionHandler()
            }
        }

        healthStore.execute(observer)
        activeObserverQueries.append(observer)

        // Enable background delivery
        healthStore.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { success, error in
            if !success {
                print("Failed to enable background delivery for \(sampleType): \(error?.localizedDescription ?? "unknown error")")
            }
        }
    }

    private func runAnchoredFetch(for sampleType: HKSampleType, anchorKey: String, completion: (() -> Void)? = nil) {
        let anchor = loadAnchor(forKey: anchorKey)

        let anchoredQuery = HKAnchoredObjectQuery(type: sampleType, predicate: nil, anchor: anchor, limit: HKObjectQueryNoLimit) { [weak self] _, newSamples, deletedObjects, newAnchor, error in
            if let error = error {
                print("Anchored query error for \(sampleType): \(error.localizedDescription)")
                completion?()
                return
            }

            if let newAnchor = newAnchor {
                self?.saveAnchor(newAnchor, forKey: anchorKey)
            }

            self?.handleUpdates(for: sampleType, newSamples: newSamples ?? [], deletedObjects: deletedObjects ?? [])
            completion?()
        }

        healthStore.execute(anchoredQuery)
    }

    private func handleUpdates(for sampleType: HKSampleType, newSamples: [HKSample], deletedObjects: [HKDeletedObject]) {
        DispatchQueue.main.async {
            if let quantityType = sampleType as? HKQuantityType {
                switch quantityType.identifier {
                case HKQuantityTypeIdentifier.stepCount.rawValue:
                    self.fetchTodaysData()
                    self.fetchWeeklySteps()
                case HKQuantityTypeIdentifier.distanceWalkingRunning.rawValue:
                    self.fetchTodaysData()
                case HKQuantityTypeIdentifier.bodyMass.rawValue:
                    self.fetchMostRecentSample(for: .bodyMass) { [weak self] sample in
                        if let sample = sample as? HKQuantitySample {
                            let weight = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                            DispatchQueue.main.async {
                                self?.userWeight = weight
                            }
                        }
                    }
                case HKQuantityTypeIdentifier.height.rawValue:
                    self.fetchMostRecentSample(for: .height) { [weak self] sample in
                        if let sample = sample as? HKQuantitySample {
                            let height = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
                            DispatchQueue.main.async {
                                self?.userHeight = height
                            }
                        }
                    }
                default:
                    break
                }
            }
        }
    }

    // MARK: - Anchor Persistence
    private func loadAnchor(forKey key: String) -> HKQueryAnchor? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            let anchor = try NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: data)
            return anchor
        } catch {
            print("Failed to unarchive HKQueryAnchor for key \(key): \(error)")
            return nil
        }
    }

    private func saveAnchor(_ anchor: HKQueryAnchor, forKey key: String) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to archive HKQueryAnchor for key \(key): \(error)")
        }
    }
}

// MARK: - Supporting Models
struct DailyStep: Identifiable {
    let id = UUID()
    let day: String
    let steps: Int
    let date: Date
}

struct HealthMetric {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let progress: Double
}

