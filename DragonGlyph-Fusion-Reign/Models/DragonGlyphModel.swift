//
//  DragonGlyphModel.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import Foundation
import SwiftUI

// MARK: - Glyph Type
enum GlyphType: String, CaseIterable, Codable {
    case fire = "Fire"
    case frost = "Frost"
    case storm = "Storm"
    case earth = "Earth"
    case shadow = "Shadow"
    case light = "Light"
    
    // Fused glyphs
    case inferno = "Inferno"       // Fire + Fire
    case blizzard = "Blizzard"     // Frost + Frost
    case tempest = "Tempest"       // Storm + Storm
    case mountain = "Mountain"     // Earth + Earth
    case void = "Void"             // Shadow + Shadow
    case radiance = "Radiance"     // Light + Light
    
    // Combined glyphs
    case magma = "Magma"           // Fire + Earth
    case steam = "Steam"           // Fire + Frost
    case lightning = "Lightning"   // Fire + Storm
    case eclipse = "Eclipse"       // Shadow + Light
    case aurora = "Aurora"         // Frost + Light
    case quake = "Quake"           // Earth + Storm
    
    var color: Color {
        switch self {
        case .fire, .inferno, .magma, .lightning:
            return Color(hex: "#FF4D00")
        case .frost, .blizzard, .steam:
            return Color(hex: "#00E0FF")
        case .storm, .tempest, .quake:
            return Color(hex: "#FFB347")
        case .earth, .mountain:
            return Color(hex: "#8B4513")
        case .shadow, .void, .eclipse:
            return Color(hex: "#2A2A3E")
        case .light, .radiance, .aurora:
            return Color(hex: "#FFFFFF")
        }
    }
    
    var symbol: String {
        switch self {
        case .fire: return "🔥"
        case .frost: return "❄️"
        case .storm: return "⚡"
        case .earth: return "🪨"
        case .shadow: return "🌑"
        case .light: return "✨"
        case .inferno: return "🌋"
        case .blizzard: return "🌨️"
        case .tempest: return "⛈️"
        case .mountain: return "⛰️"
        case .void: return "🕳️"
        case .radiance: return "💫"
        case .magma: return "🌋"
        case .steam: return "💨"
        case .lightning: return "⚡"
        case .eclipse: return "🌘"
        case .aurora: return "🌌"
        case .quake: return "💥"
        }
    }
    
    var powerLevel: Int {
        switch self {
        case .fire, .frost, .storm, .earth, .shadow, .light:
            return 1
        case .inferno, .blizzard, .tempest, .mountain, .void, .radiance:
            return 2
        case .magma, .steam, .lightning, .eclipse, .aurora, .quake:
            return 3
        }
    }
}

// MARK: - Dragon Glyph
struct DragonGlyph: Identifiable, Codable, Equatable {
    let id: UUID
    let type: GlyphType
    var position: GridPosition
    var isSelected: Bool
    var isMatched: Bool
    
    init(id: UUID = UUID(), type: GlyphType, position: GridPosition, isSelected: Bool = false, isMatched: Bool = false) {
        self.id = id
        self.type = type
        self.position = position
        self.isSelected = isSelected
        self.isMatched = isMatched
    }
}

// MARK: - Grid Position
struct GridPosition: Codable, Equatable, Hashable {
    let row: Int
    let column: Int
}

// MARK: - Fusion Rules
struct FusionRules {
    static func canFuse(_ glyph1: GlyphType, _ glyph2: GlyphType) -> Bool {
        return getFusionResult(glyph1, glyph2) != nil
    }
    
    static func getFusionResult(_ glyph1: GlyphType, _ glyph2: GlyphType) -> GlyphType? {
        let combinations: [(GlyphType, GlyphType, GlyphType)] = [
            // Same type fusions
            (.fire, .fire, .inferno),
            (.frost, .frost, .blizzard),
            (.storm, .storm, .tempest),
            (.earth, .earth, .mountain),
            (.shadow, .shadow, .void),
            (.light, .light, .radiance),
            
            // Mixed fusions
            (.fire, .earth, .magma),
            (.earth, .fire, .magma),
            (.fire, .frost, .steam),
            (.frost, .fire, .steam),
            (.fire, .storm, .lightning),
            (.storm, .fire, .lightning),
            (.shadow, .light, .eclipse),
            (.light, .shadow, .eclipse),
            (.frost, .light, .aurora),
            (.light, .frost, .aurora),
            (.earth, .storm, .quake),
            (.storm, .earth, .quake)
        ]
        
        return combinations.first { $0.0 == glyph1 && $0.1 == glyph2 }?.2
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

