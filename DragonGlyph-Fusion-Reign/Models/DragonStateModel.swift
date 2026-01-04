//
//  DragonStateModel.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import Foundation
import SwiftUI

// MARK: - Dragon State
enum DragonState: String, Codable {
    case dormant = "Dormant"
    case flickering = "Flickering"
    case awake = "Awake"
    case powerful = "Powerful"
    
    var description: String {
        switch self {
        case .dormant:
            return "The dragon slumbers, its heart barely beating."
        case .flickering:
            return "Sparks of life return to the ancient beast."
        case .awake:
            return "The dragon's eyes open, scanning its domain."
        case .powerful:
            return "The dragon rises, its power fully restored!"
        }
    }
    
    var energyThreshold: Int {
        switch self {
        case .dormant: return 0
        case .flickering: return 500
        case .awake: return 2000
        case .powerful: return 5000
        }
    }
    
    var heartColor: Color {
        switch self {
        case .dormant:
            return Color(hex: "#2A2A3E")
        case .flickering:
            return Color(hex: "#FF4D00").opacity(0.5)
        case .awake:
            return Color(hex: "#FF4D00")
        case .powerful:
            return Color(hex: "#FFB347")
        }
    }
}

// MARK: - Dragon Blessing (Power-Up)
struct DragonBlessing: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let cost: Int
    var isUnlocked: Bool
    var count: Int
    
    init(id: UUID = UUID(), 
         name: String, 
         description: String, 
         icon: String, 
         cost: Int, 
         isUnlocked: Bool = false, 
         count: Int = 0) {
        self.id = id
        self.name = name
        self.description = description
        self.icon = icon
        self.cost = cost
        self.isUnlocked = isUnlocked
        self.count = count
    }
}

// MARK: - Blessing Factory
struct BlessingFactory {
    static func createDefaultBlessings() -> [DragonBlessing] {
        return [
            DragonBlessing(
                name: "Ember Sight",
                description: "Reveals the best move for your next turn.",
                icon: "eye.fill",
                cost: 50,
                isUnlocked: true,
                count: 3
            ),
            DragonBlessing(
                name: "Timewyrm's Patience",
                description: "Adds 30 seconds to the current chamber's timer.",
                icon: "clock.fill",
                cost: 75,
                isUnlocked: true,
                count: 2
            ),
            DragonBlessing(
                name: "Scale Shatter",
                description: "Destroys a selected glyph and refills the grid.",
                icon: "hammer.fill",
                cost: 100,
                isUnlocked: true,
                count: 2
            ),
            DragonBlessing(
                name: "Dragon's Fury",
                description: "Doubles points for the next 3 matches.",
                icon: "flame.fill",
                cost: 150,
                count: 1
            )
        ]
    }
}

// MARK: - Player Progress
struct PlayerProgress: Codable {
    var totalEnergy: Int
    var dragonState: DragonState
    var chambersCompleted: Int
    var totalScore: Int
    var glyphsDiscovered: Set<String>
    var currentDifficulty: Difficulty
    
    init(totalEnergy: Int = 0,
         dragonState: DragonState = .dormant,
         chambersCompleted: Int = 0,
         totalScore: Int = 0,
         glyphsDiscovered: Set<String> = [],
         currentDifficulty: Difficulty = .hatchling) {
        self.totalEnergy = totalEnergy
        self.dragonState = dragonState
        self.chambersCompleted = chambersCompleted
        self.totalScore = totalScore
        self.glyphsDiscovered = glyphsDiscovered
        self.currentDifficulty = currentDifficulty
    }
    
    mutating func updateDragonState() {
        if totalEnergy >= DragonState.powerful.energyThreshold {
            dragonState = .powerful
        } else if totalEnergy >= DragonState.awake.energyThreshold {
            dragonState = .awake
        } else if totalEnergy >= DragonState.flickering.energyThreshold {
            dragonState = .flickering
        } else {
            dragonState = .dormant
        }
    }
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let playerName: String
    let score: Int
    let dragonFavor: Int // Combination of score, energy, and chambers completed
    let timestamp: Date
    
    init(id: UUID = UUID(), 
         playerName: String, 
         score: Int, 
         dragonFavor: Int, 
         timestamp: Date = Date()) {
        self.id = id
        self.playerName = playerName
        self.score = score
        self.dragonFavor = dragonFavor
        self.timestamp = timestamp
    }
}

