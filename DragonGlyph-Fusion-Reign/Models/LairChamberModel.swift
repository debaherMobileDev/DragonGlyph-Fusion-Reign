//
//  LairChamberModel.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import Foundation
import SwiftUI

// MARK: - Lair Chamber (Level)
struct LairChamber: Identifiable, Codable {
    let id: UUID
    let chamberNumber: Int
    let name: String
    let description: String
    let gridSize: Int
    let targetScore: Int
    let timeLimit: Int // seconds, 0 = no limit
    let difficulty: Difficulty
    var isUnlocked: Bool
    var bestScore: Int
    var isCompleted: Bool
    
    init(id: UUID = UUID(), 
         chamberNumber: Int, 
         name: String, 
         description: String, 
         gridSize: Int, 
         targetScore: Int, 
         timeLimit: Int = 0,
         difficulty: Difficulty,
         isUnlocked: Bool = false, 
         bestScore: Int = 0, 
         isCompleted: Bool = false) {
        self.id = id
        self.chamberNumber = chamberNumber
        self.name = name
        self.description = description
        self.gridSize = gridSize
        self.targetScore = targetScore
        self.timeLimit = timeLimit
        self.difficulty = difficulty
        self.isUnlocked = isUnlocked
        self.bestScore = bestScore
        self.isCompleted = isCompleted
    }
    
    var themeColor: Color {
        switch chamberNumber {
        case 1...3:
            return Color(hex: "#FF4D00") // Ember Vault
        case 4...6:
            return Color(hex: "#00E0FF") // Frostroot Cave
        case 7...9:
            return Color(hex: "#FFB347") // Stormspire Peak
        default:
            return Color(hex: "#2A2A3E")
        }
    }
}

// MARK: - Difficulty
enum Difficulty: String, Codable, CaseIterable {
    case hatchling = "Hatchling"
    case wyrm = "Wyrm"
    case ancientOne = "Ancient One"
    
    var scoreMultiplier: Double {
        switch self {
        case .hatchling: return 1.0
        case .wyrm: return 1.5
        case .ancientOne: return 2.0
        }
    }
    
    var timePenalty: Double {
        switch self {
        case .hatchling: return 0.8
        case .wyrm: return 1.0
        case .ancientOne: return 1.2
        }
    }
}

// MARK: - Chamber Factory
struct ChamberFactory {
    static func createDefaultChambers() -> [LairChamber] {
        return [
            // Ember Vault Chambers (1-3)
            LairChamber(
                chamberNumber: 1,
                name: "Ember Vault - Dawn",
                description: "The dragon's heart flickers weakly. Begin your journey.",
                gridSize: 4,
                targetScore: 100,
                timeLimit: 120,
                difficulty: .hatchling,
                isUnlocked: true
            ),
            LairChamber(
                chamberNumber: 2,
                name: "Ember Vault - Spark",
                description: "Flames dance upon ancient stone.",
                gridSize: 5,
                targetScore: 250,
                timeLimit: 150,
                difficulty: .hatchling
            ),
            LairChamber(
                chamberNumber: 3,
                name: "Ember Vault - Blaze",
                description: "The fire grows stronger within the vault.",
                gridSize: 5,
                targetScore: 400,
                timeLimit: 180,
                difficulty: .wyrm
            ),
            
            // Frostroot Cave Chambers (4-6)
            LairChamber(
                chamberNumber: 4,
                name: "Frostroot Cave - Chill",
                description: "Ancient ice preserves forgotten power.",
                gridSize: 6,
                targetScore: 600,
                timeLimit: 200,
                difficulty: .wyrm
            ),
            LairChamber(
                chamberNumber: 5,
                name: "Frostroot Cave - Frost",
                description: "Crystalline formations pulse with magic.",
                gridSize: 6,
                targetScore: 800,
                timeLimit: 220,
                difficulty: .wyrm
            ),
            LairChamber(
                chamberNumber: 6,
                name: "Frostroot Cave - Glacier",
                description: "The frozen heart of the mountain awakens.",
                gridSize: 7,
                targetScore: 1000,
                timeLimit: 240,
                difficulty: .ancientOne
            ),
            
            // Stormspire Peak Chambers (7-9)
            LairChamber(
                chamberNumber: 7,
                name: "Stormspire Peak - Thunder",
                description: "Lightning arcs between ancient spires.",
                gridSize: 7,
                targetScore: 1300,
                timeLimit: 260,
                difficulty: .ancientOne
            ),
            LairChamber(
                chamberNumber: 8,
                name: "Stormspire Peak - Tempest",
                description: "The storm's fury knows no bounds.",
                gridSize: 8,
                targetScore: 1600,
                timeLimit: 280,
                difficulty: .ancientOne
            ),
            LairChamber(
                chamberNumber: 9,
                name: "Stormspire Peak - Apex",
                description: "At the peak, the dragon's true power awaits.",
                gridSize: 8,
                targetScore: 2000,
                timeLimit: 300,
                difficulty: .ancientOne
            )
        ]
    }
}

