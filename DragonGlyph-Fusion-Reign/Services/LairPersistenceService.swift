//
//  LairPersistenceService.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import Foundation

// MARK: - Lair Persistence Service
class LairPersistenceService {
    static let shared = LairPersistenceService()
    
    private let userDefaults = UserDefaults.standard
    
    // Keys
    private let progressKey = "dragonGlyph.playerProgress"
    private let chambersKey = "dragonGlyph.chambers"
    private let blessingsKey = "dragonGlyph.blessings"
    private let leaderboardKey = "dragonGlyph.leaderboard"
    private let settingsKey = "dragonGlyph.settings"
    
    private init() {}
    
    // MARK: - Player Progress
    func saveProgress(_ progress: PlayerProgress) {
        if let encoded = try? JSONEncoder().encode(progress) {
            userDefaults.set(encoded, forKey: progressKey)
        }
    }
    
    func loadProgress() -> PlayerProgress {
        guard let data = userDefaults.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode(PlayerProgress.self, from: data) else {
            return PlayerProgress()
        }
        return progress
    }
    
    // MARK: - Chambers
    func saveChambers(_ chambers: [LairChamber]) {
        if let encoded = try? JSONEncoder().encode(chambers) {
            userDefaults.set(encoded, forKey: chambersKey)
        }
    }
    
    func loadChambers() -> [LairChamber] {
        guard let data = userDefaults.data(forKey: chambersKey),
              let chambers = try? JSONDecoder().decode([LairChamber].self, from: data) else {
            return ChamberFactory.createDefaultChambers()
        }
        return chambers
    }
    
    // MARK: - Blessings
    func saveBlessings(_ blessings: [DragonBlessing]) {
        if let encoded = try? JSONEncoder().encode(blessings) {
            userDefaults.set(encoded, forKey: blessingsKey)
        }
    }
    
    func loadBlessings() -> [DragonBlessing] {
        guard let data = userDefaults.data(forKey: blessingsKey),
              let blessings = try? JSONDecoder().decode([DragonBlessing].self, from: data) else {
            return BlessingFactory.createDefaultBlessings()
        }
        return blessings
    }
    
    // MARK: - Leaderboard
    func saveLeaderboard(_ entries: [LeaderboardEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: leaderboardKey)
        }
    }
    
    func loadLeaderboard() -> [LeaderboardEntry] {
        guard let data = userDefaults.data(forKey: leaderboardKey),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else {
            return []
        }
        return entries.sorted { $0.dragonFavor > $1.dragonFavor }
    }
    
    func addLeaderboardEntry(_ entry: LeaderboardEntry) {
        var leaderboard = loadLeaderboard()
        leaderboard.append(entry)
        leaderboard = Array(leaderboard.sorted { $0.dragonFavor > $1.dragonFavor }.prefix(100))
        saveLeaderboard(leaderboard)
    }
    
    // MARK: - Settings
    func saveSettings(_ settings: GameSettings) {
        if let encoded = try? JSONEncoder().encode(settings) {
            userDefaults.set(encoded, forKey: settingsKey)
        }
    }
    
    func loadSettings() -> GameSettings {
        guard let data = userDefaults.data(forKey: settingsKey),
              let settings = try? JSONDecoder().decode(GameSettings.self, from: data) else {
            return GameSettings()
        }
        return settings
    }
    
    // MARK: - Reset Game
    func resetAllData() {
        userDefaults.removeObject(forKey: progressKey)
        userDefaults.removeObject(forKey: chambersKey)
        userDefaults.removeObject(forKey: blessingsKey)
        // Keep leaderboard and settings
    }
}

// MARK: - Game Settings
struct GameSettings: Codable {
    var soundEnabled: Bool
    var musicEnabled: Bool
    var hapticsEnabled: Bool
    var currentDifficulty: Difficulty
    
    init(soundEnabled: Bool = true,
         musicEnabled: Bool = true,
         hapticsEnabled: Bool = true,
         currentDifficulty: Difficulty = .hatchling) {
        self.soundEnabled = soundEnabled
        self.musicEnabled = musicEnabled
        self.hapticsEnabled = hapticsEnabled
        self.currentDifficulty = currentDifficulty
    }
}

