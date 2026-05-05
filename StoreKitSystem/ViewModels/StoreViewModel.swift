//
//  StoreViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 5/4/26.
//

import Foundation
import StoreKit
import Observation

/// Manages store state and business logic
/// Single Responsibility: Coordinate between Service and View
@Observable
@MainActor
final class StoreViewModel {
    
    // MARK: - Observable State
    var products: [SubscriptionProduct] = []
    var isLoading = false
    var isPurchasing = false
    var errorMessage: String?
    var isPremiumUser = false
    
    private let service = StoreKitService.shared
    
    // MARK: - Initialization
    
    init() {
        // Don't load in init - let the view trigger it with .task
    }
    
    // MARK: - Public Methods
    
    func loadProducts() async {
        print("🔍 loadProducts() called")
        
        // Show mock data immediately for testing
        products = createMockProducts()
        print("📦 Mock products created: \(products.count) products")
        print("📦 Product details: \(products)")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let storeProducts = try await service.fetchProducts()
            print("✅ StoreKit products loaded: \(storeProducts.count)")
            
            // Only replace mock products if we actually got real products
            if !storeProducts.isEmpty {
                products = storeProducts.map { convertToSubscriptionProduct($0) }
            } else {
                print("⚠️ No StoreKit products, keeping mock data")
            }
        } catch {
            print("❌ StoreKit failed: \(error)")
            // Already have mock data, just log error
            print("Using mock data instead")
        }
        
        isLoading = false
        print("📦 Final products: \(products.count) products")
    }
    
    func purchase(_ subscriptionProduct: SubscriptionProduct) async {
        guard let product = subscriptionProduct.product else {
            // Mock purchase for testing
            isPremiumUser = true
            return
        }
        
        isPurchasing = true
        errorMessage = nil
        
        do {
            let success = try await service.purchase(product)
            if success {
                isPremiumUser = true
            }
        } catch {
            errorMessage = "Purchase failed"
        }
        
        isPurchasing = false
    }
    
    func restorePurchases() async {
        isPurchasing = true
        errorMessage = nil
        
        do {
            let success = try await service.restorePurchases()
            if success {
                isPremiumUser = true
            } else {
                errorMessage = "No purchases found"
            }
        } catch {
            errorMessage = "Restore failed"
        }
        
        isPurchasing = false
    }
    
    // MARK: - Private Helpers
    
    private func checkPremiumStatus() async {
        isPremiumUser = await service.checkSubscriptionStatus()
    }
    
    private func convertToSubscriptionProduct(_ product: Product) -> SubscriptionProduct {
        let isMonthly = product.id == ProductIdentifier.monthly
        let title = isMonthly ? "Monthly" : "Yearly"
        let duration = isMonthly ? "month" : "year"
        
        // Check for free trial
        var hasFreeTrial = false
        var trialDuration: String?
        
        if let introOffer = product.subscription?.introductoryOffer,
           introOffer.paymentMode == .freeTrial {
            hasFreeTrial = true
            let period = introOffer.period
            trialDuration = "\(period.value) \(formatPeriodUnit(period.unit))"
        }
        
        return SubscriptionProduct(
            id: product.id,
            title: title,
            price: product.displayPrice,
            duration: duration,
            hasFreeTrial: hasFreeTrial,
            freeTrialDuration: trialDuration,
            product: product
        )
    }
    
    private func formatPeriodUnit(_ unit: Product.SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "month"
        case .year: return "year"
        @unknown default: return ""
        }
    }
    
    /// Creates mock products for Simulator testing
    private func createMockProducts() -> [SubscriptionProduct] {
        [
            SubscriptionProduct(
                id: ProductIdentifier.monthly,
                title: "Monthly",
                price: "$2.99",
                duration: "month",
                hasFreeTrial: true,
                freeTrialDuration: "1 month",
                product: nil
            ),
            SubscriptionProduct(
                id: ProductIdentifier.yearly,
                title: "Yearly",
                price: "$12.99",
                duration: "year",
                hasFreeTrial: true,
                freeTrialDuration: "1 month",
                product: nil
            )
        ]
    }
}

