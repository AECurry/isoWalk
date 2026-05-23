//
//  PaywallView.swift
//  isoWalk
//
//  Created by AnnElaine on 5/1/26.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Binding var isPresented: Bool
    
    // Read directly from the shared singleton instead of wrapping it in @State.
    // This allows the view to read the true status instantly without an initialization loop.
    private var viewModel: StoreViewModel { StoreViewModel.shared }
    
    @State private var selectedID = ProductIdentifier.yearly
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // If the app layout as a whole hasn't completed its background check, show a clean background
                if !viewModel.hasCheckedStatus {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                        .overlay(ProgressView())
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            headerSection
                            
                            if viewModel.isLoading && viewModel.products.isEmpty {
                                ProgressView("Loading...")
                                    .padding(.top, 40)
                            } else {
                                productListSection
                            }
                            
                            Spacer(minLength: 40)
                            
                            bottomSection
                                .padding(.horizontal, 24)
                                .padding(.bottom, 32)
                        }
                        .frame(minHeight: geometry.size.height)
                    }
                }
            }
        }
        .onChange(of: viewModel.isPremiumUser) { _, isPremium in
            if isPremium {
                isPresented = false
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { _ in StoreViewModel.shared.errorMessage = nil }
        )) {
            Button("OK") { StoreViewModel.shared.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 24) {
            Text("Unlock isoWalk Premium")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Transform your daily walks with real-time voice coaching. Built on the clinically-studied 3-3 interval method from Japan.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 20)
    }
    
    private var productListSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.products) { product in
                PlanOptionView(product: product, isSelected: selectedID == product.id)
                    .contentShape(Rectangle()) // Makes the whole row easily tappable
                    .onTapGesture {
                        selectedID = product.id
                    }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    private var bottomSection: some View {
        VStack(spacing: 16) {
            Button {
                if let product = viewModel.products.first(where: { $0.id == selectedID }) {
                    Task { await viewModel.purchase(product) }
                }
            } label: {
                ZStack {
                    if viewModel.isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        let hasTrial = viewModel.products.first(where: { $0.id == selectedID })?.hasFreeTrial ?? false
                        Text(hasTrial ? "Start Free Trial" : "Subscribe Now")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(viewModel.isPurchasing)
            
            Button("Restore Purchases") {
                Task { await viewModel.restorePurchases() }
            }
            .font(.footnote)
            .bold()
            
            HStack {
                Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Text("|")
                Link("Privacy", destination: URL(string: "https://sites.google.com/view/isowalk/privacy-policy")!)
            }
            .font(.caption2)
            .foregroundColor(.blue)
        }
    }
}

// MARK: - PlanOptionView Helper (Placed safely in file scope)
struct PlanOptionView: View {
    let product: SubscriptionProduct
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                Text(priceText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var priceText: String {
        if let intro = product.appleProduct.subscription?.introductoryOffer {
            let unit = intro.period.unit
            let count = intro.period.value
            return "Free for \(count) \(unit)s, then \(product.displayPrice)"
        } else {
            let duration = product.id.contains("Monthly") ? "month" : "year"
            return "\(product.displayPrice) / \(duration)"
        }
    }
}

#Preview {
    PaywallView(isPresented: .constant(true))
}

