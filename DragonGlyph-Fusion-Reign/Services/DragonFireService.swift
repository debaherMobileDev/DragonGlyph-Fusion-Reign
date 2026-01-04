//
//  DragonFireService.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import Foundation
import SwiftUI

// MARK: - Dragon Fire Service (Game Logic Engine)
class DragonFireService {
    static let shared = DragonFireService()
    
    private init() {}
    
    // MARK: - Grid Generation
    func generateGrid(size: Int, difficulty: Difficulty) -> [[DragonGlyph]] {
        var grid: [[DragonGlyph]] = []
        let baseTypes: [GlyphType] = [.fire, .frost, .storm, .earth, .shadow, .light]
        
        for row in 0..<size {
            var rowGlyphs: [DragonGlyph] = []
            for col in 0..<size {
                let randomType = baseTypes.randomElement() ?? .fire
                let glyph = DragonGlyph(
                    type: randomType,
                    position: GridPosition(row: row, column: col)
                )
                rowGlyphs.append(glyph)
            }
            grid.append(rowGlyphs)
        }
        
        return grid
    }
    
    // MARK: - Match Detection
    func findMatches(in grid: [[DragonGlyph]]) -> [DragonGlyph] {
        var matches: [DragonGlyph] = []
        let size = grid.count
        
        // Check horizontal matches (3 or more in a row)
        for row in 0..<size {
            var streak = 1
            var currentType = grid[row][0].type
            
            for col in 1..<size {
                if grid[row][col].type == currentType {
                    streak += 1
                } else {
                    if streak >= 3 {
                        for i in (col - streak)..<col {
                            if !matches.contains(where: { $0.id == grid[row][i].id }) {
                                matches.append(grid[row][i])
                            }
                        }
                    }
                    streak = 1
                    currentType = grid[row][col].type
                }
            }
            
            if streak >= 3 {
                for i in (size - streak)..<size {
                    if !matches.contains(where: { $0.id == grid[row][i].id }) {
                        matches.append(grid[row][i])
                    }
                }
            }
        }
        
        // Check vertical matches
        for col in 0..<size {
            var streak = 1
            var currentType = grid[0][col].type
            
            for row in 1..<size {
                if grid[row][col].type == currentType {
                    streak += 1
                } else {
                    if streak >= 3 {
                        for i in (row - streak)..<row {
                            if !matches.contains(where: { $0.id == grid[i][col].id }) {
                                matches.append(grid[i][col])
                            }
                        }
                    }
                    streak = 1
                    currentType = grid[row][col].type
                }
            }
            
            if streak >= 3 {
                for i in (size - streak)..<size {
                    if !matches.contains(where: { $0.id == grid[i][col].id }) {
                        matches.append(grid[i][col])
                    }
                }
            }
        }
        
        return matches
    }
    
    // MARK: - Scoring
    func calculateScore(matches: [DragonGlyph], difficulty: Difficulty, comboMultiplier: Int = 1) -> Int {
        var baseScore = 0
        
        for glyph in matches {
            baseScore += glyph.type.powerLevel * 10
        }
        
        let matchBonus = matches.count >= 5 ? 50 : 0
        let difficultyMultiplier = difficulty.scoreMultiplier
        
        return Int(Double(baseScore + matchBonus) * difficultyMultiplier * Double(comboMultiplier))
    }
    
    // MARK: - Glyph Fusion
    func fuseGlyphs(_ glyph1: DragonGlyph, _ glyph2: DragonGlyph) -> GlyphType? {
        return FusionRules.getFusionResult(glyph1.type, glyph2.type)
    }
    
    // MARK: - Grid Refill
    func refillGrid(_ grid: inout [[DragonGlyph]], removedPositions: [GridPosition]) {
        let size = grid.count
        let baseTypes: [GlyphType] = [.fire, .frost, .storm, .earth, .shadow, .light]
        
        // Sort positions by row (top to bottom)
        let sortedPositions = removedPositions.sorted { $0.row < $1.row }
        
        // Drop existing glyphs down
        for col in 0..<size {
            var emptySpaces = 0
            
            // Count and remove matched glyphs
            for row in (0..<size).reversed() {
                if sortedPositions.contains(where: { $0.row == row && $0.column == col }) {
                    emptySpaces += 1
                } else if emptySpaces > 0 {
                    // Move glyph down
                    grid[row + emptySpaces][col] = grid[row][col]
                    grid[row + emptySpaces][col].position = GridPosition(row: row + emptySpaces, column: col)
                }
            }
            
            // Fill top with new glyphs
            for row in 0..<emptySpaces {
                let randomType = baseTypes.randomElement() ?? .fire
                grid[row][col] = DragonGlyph(
                    type: randomType,
                    position: GridPosition(row: row, column: col)
                )
            }
        }
    }
    
    // MARK: - Swap Validation
    func isValidSwap(from: GridPosition, to: GridPosition, gridSize: Int) -> Bool {
        // Check if positions are adjacent
        let rowDiff = abs(from.row - to.row)
        let colDiff = abs(from.column - to.column)
        
        // Must be adjacent (not diagonal)
        return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1)
    }
    
    // MARK: - Hint System
    func findBestMove(in grid: [[DragonGlyph]]) -> (from: GridPosition, to: GridPosition)? {
        let size = grid.count
        
        for row in 0..<size {
            for col in 0..<size {
                // Try swapping with adjacent cells
                let adjacentPositions = [
                    GridPosition(row: row - 1, column: col),
                    GridPosition(row: row + 1, column: col),
                    GridPosition(row: row, column: col - 1),
                    GridPosition(row: row, column: col + 1)
                ]
                
                for adjacent in adjacentPositions {
                    if adjacent.row >= 0 && adjacent.row < size &&
                       adjacent.column >= 0 && adjacent.column < size {
                        
                        // Simulate swap
                        var testGrid = grid
                        let temp = testGrid[row][col]
                        testGrid[row][col] = testGrid[adjacent.row][adjacent.column]
                        testGrid[adjacent.row][adjacent.column] = temp
                        
                        // Check if swap creates matches
                        let matches = findMatches(in: testGrid)
                        if !matches.isEmpty {
                            return (GridPosition(row: row, column: col), adjacent)
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Dragon's Favor Calculation
    func calculateDragonsFavor(score: Int, energy: Int, chambersCompleted: Int) -> Int {
        return score + (energy * 2) + (chambersCompleted * 100)
    }
}

