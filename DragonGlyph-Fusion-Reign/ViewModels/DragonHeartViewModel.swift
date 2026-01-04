//
//  DragonHeartViewModel.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import Foundation
import SwiftUI
import Combine

// MARK: - Dragon Heart View Model
class DragonHeartViewModel: ObservableObject {
    @Published var playerProgress: PlayerProgress
    @Published var chambers: [LairChamber]
    @Published var blessings: [DragonBlessing]
    @Published var settings: GameSettings
    @Published var selectedChamber: LairChamber?
    @Published var showChamber = false
    @Published var heartPulseAnimation = false
    
    private let persistenceService = LairPersistenceService.shared
    private let gameService = DragonFireService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.playerProgress = persistenceService.loadProgress()
        self.chambers = persistenceService.loadChambers()
        self.blessings = persistenceService.loadBlessings()
        self.settings = persistenceService.loadSettings()
        
        startHeartAnimation()
    }
    
    // MARK: - Heart Animation
    private func startHeartAnimation() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                withAnimation(.easeInOut(duration: 0.8)) {
                    self?.heartPulseAnimation.toggle()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Chamber Management
    func selectChamber(_ chamber: LairChamber) {
        selectedChamber = chamber
        showChamber = true
    }
    
    func completeChamber(chamberNumber: Int, score: Int, energy: Int) {
        // Update chamber
        if let index = chambers.firstIndex(where: { $0.chamberNumber == chamberNumber }) {
            chambers[index].isCompleted = true
            chambers[index].bestScore = max(chambers[index].bestScore, score)
            
            // Unlock next chamber
            if chamberNumber < chambers.count {
                if let nextIndex = chambers.firstIndex(where: { $0.chamberNumber == chamberNumber + 1 }) {
                    chambers[nextIndex].isUnlocked = true
                }
            }
        }
        
        // Update progress
        playerProgress.totalEnergy += energy
        playerProgress.totalScore += score
        playerProgress.chambersCompleted += 1
        playerProgress.updateDragonState()
        
        // Save
        persistenceService.saveChambers(chambers)
        persistenceService.saveProgress(playerProgress)
        
        // Add to leaderboard
        let dragonFavor = gameService.calculateDragonsFavor(
            score: playerProgress.totalScore,
            energy: playerProgress.totalEnergy,
            chambersCompleted: playerProgress.chambersCompleted
        )
        
        let entry = LeaderboardEntry(
            playerName: "Dragon Keeper",
            score: playerProgress.totalScore,
            dragonFavor: dragonFavor
        )
        persistenceService.addLeaderboardEntry(entry)
    }
    
    // MARK: - Blessing Management
    func useBlessing(_ blessing: DragonBlessing) -> Bool {
        guard let index = blessings.firstIndex(where: { $0.id == blessing.id }),
              blessings[index].count > 0 else {
            return false
        }
        
        blessings[index].count -= 1
        persistenceService.saveBlessings(blessings)
        return true
    }
    
    func purchaseBlessing(_ blessing: DragonBlessing) -> Bool {
        guard playerProgress.totalEnergy >= blessing.cost else {
            return false
        }
        
        if let index = blessings.firstIndex(where: { $0.id == blessing.id }) {
            blessings[index].count += 1
            playerProgress.totalEnergy -= blessing.cost
            
            persistenceService.saveBlessings(blessings)
            persistenceService.saveProgress(playerProgress)
            return true
        }
        
        return false
    }
    
    // MARK: - Glyph Discovery
    func discoverGlyph(_ type: GlyphType) {
        playerProgress.glyphsDiscovered.insert(type.rawValue)
        persistenceService.saveProgress(playerProgress)
    }
    
    // MARK: - Settings Management
    func updateSettings(_ newSettings: GameSettings) {
        settings = newSettings
        persistenceService.saveSettings(settings)
    }
    
    // MARK: - Reset Game
    func resetGame() {
        persistenceService.resetAllData()
        playerProgress = PlayerProgress()
        chambers = ChamberFactory.createDefaultChambers()
        blessings = BlessingFactory.createDefaultBlessings()
        
        persistenceService.saveProgress(playerProgress)
        persistenceService.saveChambers(chambers)
        persistenceService.saveBlessings(blessings)
    }
}

