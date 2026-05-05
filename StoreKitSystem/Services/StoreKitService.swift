//
//  StoreKitService.swift
//  isoWalk
//
//  Created by AnnElaine on 5/4/26.
//

import Foundation
import StoreKit

/// Handles all StoreKit communication
/// Single Responsibility: Talk to Apple's servers
final class StoreKitService {
    
    // MARK: - Singleton
    static let shared = StoreKitService()
    private init() {}
    
    // MARK: - Product Loading
    
    /// Fetch products from App Store
    func fetchProducts() async throws -> [Product] {
        let products = try await Product.products(for: ProductIdentifier.allCases)
        return products
    }
    
    // MARK: - Purchase Handling
    
    /// Purchase a product
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            return await handleVerification(verification)
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }
    
    /// Restore previous purchases
    func restorePurchases() async throws -> Bool {
        try await AppStore.sync()
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if ProductIdentifier.allCases.contains(transaction.productID) {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Premium Status Check
    
    /// Check if user has active subscription
    func checkSubscriptionStatus() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if ProductIdentifier.allCases.contains(transaction.productID) {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Private Helpers
    
    private func handleVerification(_ verification: VerificationResult<Transaction>) async -> Bool {
        switch verification {
        case .verified(let transaction):
            await transaction.finish()
            return true
        case .unverified:
            return false
        }
    }
}

