//
//  ScientificResearchContent.swift
//  isoWalk
//
//  Created by AnnElaine on 3/10/26.
//
//
//  MODEL — pure content, no UI, no logic.
//  All scientific research text lives here so it's easy to update.
//  ScientificResearchViewModel reads from this — nothing else needs to change.
//

import Foundation

enum ScientificResearchContent {

    // MARK: - Short Version
    static let shortSections: [ResearchSection] = [

        ResearchSection(
            heading: "About This Walking Method",
            body: "This app is inspired by published research on interval-style walking routines."
        ),
        ResearchSection(
            heading: "The Structure Alternates Between",
            bullets: [
                "3 minutes of comfortable walking",
                "3 minutes of brisk walking",
                "Repeated for about 30 minutes"
            ]
        ),
        ResearchSection(
            heading: "What the Research Found",
            body: "In a peer-reviewed study involving middle-aged and older adults, participants who followed this structured walking pattern experienced measurable improvements in fitness levels and certain cardiovascular health markers compared to steady-paced walking."
        ),
        ResearchSection(
            heading: "This App Is Designed to Support",
            bullets: [
                "Cardiovascular fitness",
                "Healthy movement habits",
                "Strength and endurance",
                "Consistent physical activity routines"
            ]
        ),
        ResearchSection(
            heading: "Important Note",
            body: "This app is intended for general wellness and fitness purposes only and is not a medical device. Always consult a qualified healthcare professional before beginning a new exercise program."
        )
    ]

    // MARK: - Long Version
    static let longSections: [ResearchSection] = [

        ResearchSection(
            heading: "The Science Behind the 3–3 Walk Method",
            body: "The 3–3 Walk method is inspired by research conducted by Dr. Shizue Matsuki and colleagues, published in the Journal of the American College of Cardiology (2019).\n\nIn this study, researchers examined Interval Walking Training (IWT) compared to steady-paced walking in middle-aged and older adults."
        ),
        ResearchSection(
            heading: "What Is the 3–3 Method?",
            body: "The method follows a repeating cycle:",
            bullets: [
                "3 minutes at a normal pace (approximately 40–50% of VO₂peak)",
                "3 minutes at a brisk pace (approximately 70% or higher of VO₂peak)"
            ],
            footer: "This 6-minute cycle is repeated five or more times, totaling about 30 minutes per session, at least four days per week. It is structured walking with planned intensity changes."
        ),
        ResearchSection(
            heading: "How It Differs from Normal Walking",
            body: "Traditional walking often maintains a consistent pace. The 3–3 method introduces intentional intensity intervals, alternating between higher-effort and recovery segments. This structured pattern was the focus of the study."
        ),
        ResearchSection(
            heading: "What the Study Observed",
            body: "Compared to continuous walking, participants following the interval approach experienced:",
            bullets: [
                "Increases in cardiorespiratory fitness (VO₂peak)",
                "Reductions in systolic blood pressure",
                "Improvements in leg muscle strength",
                "Associations with improved glucose markers in participants with elevated baseline levels"
            ],
            footer: "Results reflect outcomes observed within the study population and do not guarantee individual results."
        ),
        ResearchSection(
            heading: "Why This Matters",
            body: "Structured interval walking offers a time-efficient way to introduce variety and intensity into a walking routine."
        ),
        ResearchSection(
            heading: "How Matsuki isoWalk Supports the Method",
            body: "Matsuki isoWalk helps you:",
            bullets: [
                "Time your 3-minute intervals",
                "Maintain consistent sessions",
                "Track your activity",
                "Build sustainable walking habits"
            ],
            footer: "The app supports general fitness and structured movement routines."
        ),
        ResearchSection(
            heading: "Research Citation",
            body: "Matsuki, S., et al. (2019). Effects of Interval Walking Training Compared with Normal Walking Training on Cardiorespiratory Fitness and Blood Pressure in Middle-Aged and Older People. Journal of the American College of Cardiology."
        ),
        ResearchSection(
            heading: "Important Note",
            body: "Matsuki isoWalk is designed for general wellness and fitness purposes only and is not intended to diagnose, treat, or prevent any medical condition. Consult a qualified healthcare professional before beginning a new exercise program."
        )
    ]
}

// MARK: - Section Model
struct ResearchSection: Identifiable {
    let id = UUID()
    let heading: String
    var body: String? = nil
    var bullets: [String] = []
    var footer: String? = nil
}

