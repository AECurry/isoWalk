//
//  StoreViewModel.swift
//  isoWalk
//
//  Created by AnnElaine on 5/4/26.
//

import Foundation
import StoreKit
import Observation

enum ProductIdentifier {
    static let monthly = "AnnElaine.App.isoWalk.MonthlySubscribers"
    static let yearly = "AnnElaine.App.isoWalk.YearlySubscribers"
    static var all: [String] { [monthly, yearly] }
}

struct SubscriptionProduct: Identifiable {
    let id: String
    let title: String
    let displayPrice: String
    let price: Decimal
    let hasFreeTrial: Bool
    let appleProduct: Product
    
    init(from product: Product) {
        self.id = product.id
        self.title = product.id.contains("Monthly") ? "Monthly" : "Yearly"
        self.displayPrice = product.displayPrice
        self.price = product.price
        self.hasFreeTrial = product.subscription?.introductoryOffer?.paymentMode == .freeTrial
        self.appleProduct = product
    }
}

@Observable @MainActor
final class StoreViewModel {
    static let shared = StoreViewModel()
    
    var products: [SubscriptionProduct] = []
    var isLoading = false
    var isPurchasing = false
    var isPremiumUser = false
    var hasCheckedStatus = false
    var errorMessage: String?
    
    private var transactionListener: Task<Void, Never>?
    
    private init() {
        transactionListener = Task { [weak self] in
            for await result in Transaction.updates {
                await self?.handleTransaction(result)
            }
        }
        
        Task {
            await checkPremiumStatus()
            await loadProducts()
        }
    }
    
    private func handleTransaction(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        await transaction.finish()
        await checkPremiumStatus()
    }
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let storeProducts = try await Product.products(for: ProductIdentifier.all)
            products = storeProducts
                .map { SubscriptionProduct(from: $0) }
                .sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load subscriptions"
        }
    }
    
    func purchase(_ product: SubscriptionProduct) async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await product.appleProduct.purchase()
            
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await checkPremiumStatus()
                }
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase pending"
            @unknown default:
                break
            }
        } catch {
            errorMessage = "Purchase failed"
        }
    }
    
    func checkPremiumStatus() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(_) = result {
                isPremiumUser = true
                hasCheckedStatus = true
                return
            }
        }
        isPremiumUser = false
        hasCheckedStatus = true
    }
    
    func restorePurchases() async {
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            try await AppStore.sync()
            await checkPremiumStatus()
            if !isPremiumUser {
                errorMessage = "No purchases found"
            }
        } catch {
            errorMessage = "Restore failed"
        }
    }
}

