//
//  PrivacyContent.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//
//  MODEL — pure content, no UI, no logic.
//  All privacy policy text lives here so it's easy to update.
//  PrivacyViewModel reads from this — nothing else needs to change.
//

import Foundation

enum PrivacyContent {

    // MARK: - Short Version
    static let shortSections: [PrivacySection] = [

        PrivacySection(
            heading: "Your Privacy Matters",
            body: "At Matsuki isoWalk, your privacy is simple and respected."
        ),
        PrivacySection(
            heading: "What We Collect",
            bullets: [
                "Your email address (for account login and support).",
                "Walking data like steps and distance, only if you grant permission."
            ]
        ),
        PrivacySection(
            heading: "What We Do Not Do",
            bullets: [
                "We do not sell your data.",
                "We do not share your health data.",
                "We do not store payment information.",
                "Your walking and health data stay on your device."
            ]
        ),
        PrivacySection(
            heading: "The \"New Phone\" Notice",
            body: "Because your data is stored locally for maximum privacy, it will not automatically sync to a new device. If you switch to a new iPhone, your history and badges will only transfer if you perform a full encrypted device-to-device backup (such as via iCloud Backup or a physical transfer). Otherwise, your stats and badges will reset on the new device."
        ),
        PrivacySection(
            heading: "Subscriptions",
            body: "All subscriptions are handled securely by Apple through In-App Purchases."
        ),
        PrivacySection(
            heading: "Notifications",
            body: "Daily reminders and milestone messages are optional and can be turned off anytime."
        ),
        PrivacySection(
            heading: "You're in Control",
            bullets: [
                "Revoke Health or Motion permissions in Settings.",
                "Turn off notifications anytime.",
                "Contact us anytime at customersupport@beaconhilltechnologies.com"
            ],
            footer: "Your progress is personal. We designed this app to keep it that way."
        )
    ]

    // MARK: - Long Version
    static let longSections: [PrivacySection] = [

        PrivacySection(
            heading: "Privacy Policy – Beacon Hill Technologies",
            body: "Effective Date: [Insert Date]\n\nAt Beacon Hill Technologies, your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your information when you use our app, Matsuki isoWalk."
        ),
        PrivacySection(
            heading: "1. Information We Collect",
            body: "Account Information\nIf you create an account, we collect your email address. You can sign in either with Apple (using Sign in with Apple) or by creating a unique email/password for our app.\n\nHealth & Motion Data\nWe may access your HealthKit and Core Motion data, such as steps, distance, and calories, but only if you give permission. This data is stored only on your device and is not shared with us or any third parties.\n\nNotifications\nIf you opt in, we may send daily reminders, milestone notifications, or motivational messages. You can control or disable notifications at any time."
        ),
        PrivacySection(
            heading: "2. How We Use Your Information",
            bullets: [
                "To create and manage your account.",
                "To track walking sessions and progress within the app.",
                "To send notifications you have opted in for.",
                "To respond to your support requests when you contact us via email."
            ],
            footer: "We do not sell, share, or distribute your personal information to third parties."
        ),
        PrivacySection(
            heading: "3. Payments & Subscriptions",
            bullets: [
                "All purchases (monthly or yearly subscriptions) are handled exclusively through Apple In-App Purchases.",
                "We do not store or process any payment or billing information.",
                "Subscription status is managed by Apple and your device."
            ]
        ),
        PrivacySection(
            heading: "4. Data Storage & Security",
            body: "Local Storage: Your health data, walking history, and earned badges remain exclusively on your device. We do not store this data on our servers.\n\nThe \"New Phone\" Notice: Because your data is stored locally for maximum privacy, it will not automatically sync to a new device. If you switch to a new iPhone, your history and badges will only transfer if you perform a full encrypted device-to-device backup (such as via iCloud Backup or a physical transfer). Otherwise, your stats and badges will reset on the new device."
        ),
        PrivacySection(
            heading: "5. User Rights",
            bullets: [
                "You can contact us at any time at customersupport@beaconhilltechnologies.com.",
                "You can opt out of notifications at any time through your device settings.",
                "All HealthKit/Core Motion permissions can be revoked at any time in your device settings."
            ]
        ),
        PrivacySection(
            heading: "6. Children's Privacy",
            body: "Matsuki isoWalk is not intended for children under 13. We do not knowingly collect information from children under 13."
        ),
        PrivacySection(
            heading: "7. Changes to This Policy",
            body: "We may update this Privacy Policy from time to time. If we make significant changes, we will notify you in-app or via the email you provide."
        ),
        PrivacySection(
            heading: "8. Contact Us",
            body: "If you have any questions or concerns about your privacy, please contact us:\n\nBeacon Hill Technologies\nEmail: customersupport@beaconhilltechnologies.com"
        )
    ]
}

// MARK: - Section Model
struct PrivacySection: Identifiable {
    let id = UUID()
    let heading: String
    var body: String? = nil
    var bullets: [String] = []
    var footer: String? = nil
}
