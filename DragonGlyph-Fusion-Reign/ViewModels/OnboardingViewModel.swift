//
//  OnboardingViewModel.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import Foundation
import SwiftUI

// MARK: - Onboarding View Model
class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    @Published var isDemoActive = false
    @Published var demoGlyphs: [DragonGlyph] = []
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome, Dragon Keeper",
            description: "An ancient dragon slumbers in the depths. Only you can awaken its power by mastering the mystical dragon scales.",
            imageName: "flame.fill",
            color: Color(hex: "#FF4D00")
        ),
        OnboardingPage(
            title: "Discover the Glyphs",
            description: "Match three or more dragon scales of the same type to fuel the dragon's heart. Each match brings the dragon closer to awakening.",
            imageName: "square.grid.3x3.fill",
            color: Color(hex: "#00E0FF")
        ),
        OnboardingPage(
            title: "Fuse & Combine",
            description: "Combine different glyph types to create powerful fusions. Fire + Earth creates Magma. Frost + Light creates Aurora.",
            imageName: "sparkles",
            color: Color(hex: "#FFB347")
        ),
        OnboardingPage(
            title: "Explore the Lair",
            description: "Journey through the dragon's expanding lair, from the Ember Vault to the Stormspire Peak. Each chamber holds new challenges.",
            imageName: "building.columns.fill",
            color: Color(hex: "#2A2A3E")
        ),
        OnboardingPage(
            title: "Earn Dragon's Blessings",
            description: "As you progress, unlock powerful abilities: Ember Sight reveals hints, Timewyrm's Patience grants more time, and more.",
            imageName: "star.fill",
            color: Color(hex: "#FFB347")
        ),
        OnboardingPage(
            title: "Awaken the Dragon",
            description: "The dragon's heart pulses with every victory. Will you restore its ancient power and earn a place in the Keeper's Chronicle?",
            imageName: "heart.fill",
            color: Color(hex: "#FF4D00")
        )
    ]
    
    init() {
        setupDemoGlyphs()
    }
    
    private func setupDemoGlyphs() {
        let types: [GlyphType] = [.fire, .frost, .storm, .earth, .shadow, .light]
        demoGlyphs = types.enumerated().map { index, type in
            DragonGlyph(
                type: type,
                position: GridPosition(row: 0, column: index)
            )
        }
    }
    
    func nextPage() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            withAnimation {
                currentPage -= 1
            }
        }
    }
}

// MARK: - Onboarding Page
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
    let color: Color
}

