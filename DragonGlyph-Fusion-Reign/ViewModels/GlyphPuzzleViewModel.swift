//
//  GlyphPuzzleViewModel.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import Foundation
import SwiftUI
import Combine

// MARK: - Glyph Puzzle View Model
class GlyphPuzzleViewModel: ObservableObject {
    @Published var grid: [[DragonGlyph]] = []
    @Published var score: Int = 0
    @Published var energy: Int = 0
    @Published var moves: Int = 0
    @Published var timeRemaining: Int = 0
    @Published var selectedGlyph: DragonGlyph?
    @Published var isGameOver = false
    @Published var isVictory = false
    @Published var comboMultiplier = 1
    @Published var showHint = false
    @Published var hintPositions: (from: GridPosition, to: GridPosition)?
    @Published var isPaused = false
    @Published var activeBlessings: [String] = []
    
    var chamber: LairChamber
    var difficulty: Difficulty
    private let gameService = DragonFireService.shared
    private var timer: Timer?
    private var furyMovesRemaining = 0
    
    init(chamber: LairChamber, difficulty: Difficulty) {
        self.chamber = chamber
        self.difficulty = difficulty
        self.timeRemaining = Int(Double(chamber.timeLimit) * difficulty.timePenalty)
        
        setupGame()
    }
    
    // MARK: - Game Setup
    func setupGame() {
        grid = gameService.generateGrid(size: chamber.gridSize, difficulty: difficulty)
        score = 0
        energy = 0
        moves = 0
        isGameOver = false
        isVictory = false
        comboMultiplier = 1
        
        startTimer()
    }
    
    // MARK: - Timer Management
    func startTimer() {
        guard chamber.timeLimit > 0 else { return }
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame(victory: false)
            }
        }
    }
    
    func pauseGame() {
        isPaused = true
    }
    
    func resumeGame() {
        isPaused = false
    }
    
    // MARK: - Glyph Selection & Swapping
    func selectGlyph(_ glyph: DragonGlyph) {
        if let selected = selectedGlyph {
            // Try to swap
            if gameService.isValidSwap(from: selected.position, to: glyph.position, gridSize: chamber.gridSize) {
                swapGlyphs(selected, glyph)
            }
            selectedGlyph = nil
        } else {
            selectedGlyph = glyph
        }
    }
    
    private func swapGlyphs(_ glyph1: DragonGlyph, _ glyph2: DragonGlyph) {
        let pos1 = glyph1.position
        let pos2 = glyph2.position
        
        // Perform swap
        let temp = grid[pos1.row][pos1.column]
        grid[pos1.row][pos1.column] = grid[pos2.row][pos2.column]
        grid[pos2.row][pos2.column] = temp
        
        // Update positions
        grid[pos1.row][pos1.column].position = pos1
        grid[pos2.row][pos2.column].position = pos2
        
        moves += 1
        
        // Check for matches
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.processMatches()
        }
    }
    
    // MARK: - Match Processing
    private func processMatches() {
        var matches = gameService.findMatches(in: grid)
        
        if matches.isEmpty {
            comboMultiplier = 1
            return
        }
        
        var totalMatches: [DragonGlyph] = []
        
        while !matches.isEmpty {
            totalMatches.append(contentsOf: matches)
            
            // Calculate score
            let matchScore = gameService.calculateScore(
                matches: matches,
                difficulty: difficulty,
                comboMultiplier: furyMovesRemaining > 0 ? 2 : comboMultiplier
            )
            score += matchScore
            energy += matches.count * 5
            
            // Mark as matched
            for match in matches {
                grid[match.position.row][match.position.column].isMatched = true
            }
            
            // Refill grid
            let positions = matches.map { $0.position }
            gameService.refillGrid(&grid, removedPositions: positions)
            
            comboMultiplier += 1
            
            // Check for new matches after refill
            matches = gameService.findMatches(in: grid)
        }
        
        if furyMovesRemaining > 0 {
            furyMovesRemaining -= 1
            if furyMovesRemaining == 0 {
                activeBlessings.removeAll { $0 == "Dragon's Fury" }
            }
        }
        
        // Check victory condition
        if score >= chamber.targetScore {
            endGame(victory: true)
        }
    }
    
    // MARK: - Blessings
    func useEmberSight() {
        if let hint = gameService.findBestMove(in: grid) {
            hintPositions = hint
            showHint = true
            activeBlessings.append("Ember Sight")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.showHint = false
                self.hintPositions = nil
                self.activeBlessings.removeAll { $0 == "Ember Sight" }
            }
        }
    }
    
    func useTimewyrmsPatience() {
        timeRemaining += 30
        activeBlessings.append("Timewyrm's Patience")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.activeBlessings.removeAll { $0 == "Timewyrm's Patience" }
        }
    }
    
    func useScaleShatter(at position: GridPosition) {
        // Remove glyph and refill
        gameService.refillGrid(&grid, removedPositions: [position])
        activeBlessings.append("Scale Shatter")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.activeBlessings.removeAll { $0 == "Scale Shatter" }
        }
    }
    
    func useDragonsFury() {
        furyMovesRemaining = 3
        activeBlessings.append("Dragon's Fury")
    }
    
    // MARK: - Game End
    func endGame(victory: Bool) {
        timer?.invalidate()
        isGameOver = true
        isVictory = victory
    }
    
    deinit {
        timer?.invalidate()
    }
}

