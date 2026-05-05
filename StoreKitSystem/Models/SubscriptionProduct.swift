//
//  SubscriptionProduct.swift
//  isoWalk
//
//  Created by AnnElaine on 5/4/26.
//

import Foundation
import StoreKit

/// Represents a subscription product with all display information
struct SubscriptionProduct: Identifiable {
    let id: String
    let title: String
    let price: String
    let duration: String
    let hasFreeTrial: Bool
    let freeTrialDuration: String?
    let product: Product?
    
    var displayPrice: String {
        if hasFreeTrial, let trialDuration = freeTrialDuration {
            return "Free for \(trialDuration), then \(price)"
        }
        return "\(price) / \(duration)"
    }
}

/// Product identifiers - single source of truth
enum ProductIdentifier {
    static let monthly = "AnnElaine.App.isoWalk.MonthlySubscribers"
    static let yearly = "AnnElaine.App.isoWalk.YearlySubscribers"
    
    static var allCases: [String] {
        [monthly, yearly]
    }
}

