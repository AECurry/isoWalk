//
//  HealthKitManagerView.swift
//  isoWalk
//
//  Created by AnnElaine on 3/9/26.
//
//
//  SERVICE — pure business logic, zero SwiftUI.
//  Handles all HealthKit authorization and data reads.
//  Called only by HealthKitViewModel — never directly by a View.
//
//  DATA TYPES:
//  - Walking distance (active)
//  - Step count (active)
//  - Active energy burned / calories (active)
//  - Heart rate (wired but inactive until watch feature is built)
//

import Foundation
import UIKit
import HealthKit

final class HealthKitManager {

    // MARK: - Singleton
    static let shared = HealthKitManager()
    private init() {}

    // MARK: - Store
    private let store = HKHealthStore()

    // MARK: - Data Types

    // Types we READ from HealthKit
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        // Heart rate added here when watch feature is built:
        // HKObjectType.quantityType(forIdentifier: .heartRate)!
    ]

    // MARK: - Availability

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization Status

    // Returns true only if ALL required types are authorized.
    var isFullyAuthorized: Bool {
        guard isHealthKitAvailable else { return false }
        let required: [HKQuantityTypeIdentifier] = [
            .distanceWalkingRunning,
            .stepCount,
            .activeEnergyBurned
        ]
        return required.allSatisfy { identifier in
            guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return false }
            return store.authorizationStatus(for: type) == .sharingAuthorized
        }
    }

    // Returns true if the user has previously denied at least one type.
    var isDenied: Bool {
        guard isHealthKitAvailable else { return false }
        let required: [HKQuantityTypeIdentifier] = [
            .distanceWalkingRunning,
            .stepCount,
            .activeEnergyBurned
        ]
        return required.contains { identifier in
            guard let type = HKObjectType.quantityType(forIdentifier: identifier) else { return false }
            return store.authorizationStatus(for: type) == .sharingDenied
        }
    }

    // MARK: - Request Authorization

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard isHealthKitAvailable else {
            completion(false, nil)
            return
        }
        store.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            completion(success, error)
        }
    }

    // MARK: - Open Settings
    // Deep links user to iOS Settings → Privacy & Security → Health → isoWalk
    func openHealthSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
}

