//
//  PaywallView.swift
//  isoWalk
//
//  Created by AnnElaine on 5/1/26.
//

import SwiftUI

struct PaywallView: View {
    @Binding var isPresented: Bool
    @State private var viewModel = StoreViewModel()
    @State private var selectedProductID: String = ProductIdentifier.yearly
    
    var body: some View {
        VStack {
            headerSection
            Spacer()
            productListSection
            Spacer()
            subscribeButton
            footerSection
        }
        .task {
                print("🚀 .task modifier triggered")
                await viewModel.loadProducts()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: viewModel.isPremiumUser) { _, isPremium in
                if isPremium {
                    isPresented = false
                }
            }
        }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 20) {
            Text("Unlock isoWalk Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.top, 40)
            
            Text("Transform your daily walks with real-time voice coaching. Built on the clinically-studied 3-3 interval method from Japan, designed to help you build consistent, effective walking habits.")
                .font(.body)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var productListSection: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading subscriptions...")
            } else {
                VStack(spacing: 16) {
                    ForEach(viewModel.products) { product in
                        PlanOptionView(
                            product: product,
                            isSelected: selectedProductID == product.id
                        ) {
                            selectedProductID = product.id
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var subscribeButton: some View {
        Button(action: handleSubscribe) {
            if viewModel.isPurchasing {
                ProgressView()
                    .tint(.white)
            } else {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .cornerRadius(12)
        .padding(.horizontal, 24)
        .disabled(viewModel.isPurchasing || viewModel.isLoading)
    }
    
    private var footerSection: some View {
        VStack(spacing: 16) {
            Button("Restore Purchases") {
                Task {
                    await viewModel.restorePurchases()
                }
            }
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundColor(.blue)
            
            HStack(spacing: 12) {
                Link("Terms of Use",
                     destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Text("|")
                Link("Privacy Policy",
                     destination: URL(string: "https://isowalk.fit/privacy")!)
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Computed Properties
    
    private var selectedProduct: SubscriptionProduct? {
        viewModel.products.first { $0.id == selectedProductID }
    }
    
    private var buttonTitle: String {
        selectedProduct?.hasFreeTrial == true ? "Start Free Trial" : "Subscribe Now"
    }
    
    // MARK: - Actions
    
    private func handleSubscribe() {
        guard let product = selectedProduct else { return }
        Task {
            await viewModel.purchase(product)
        }
    }
}

// MARK: - Subviews

struct PlanOptionView: View {
    let product: SubscriptionProduct
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(product.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(product.displayPrice)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
                    .font(.title2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3),
                           lineWidth: isSelected ? 2 : 1)
            )
            .background(isSelected ? Color.blue.opacity(0.05) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaywallView(isPresented: .constant(true))
}

