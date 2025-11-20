//
//  StatsManager.swift
//  DF742
//

import Foundation
import Combine

class StatsManager: ObservableObject {
    static let shared = StatsManager()
    
    @Published var globalStats: GlobalStats
    @Published var gameStats: [GameType: GameStats]
    @Published var hasCompletedOnboarding: Bool
    
    private let globalStatsKey = "globalStats"
    private let gameStatsKey = "gameStats"
    private let onboardingKey = "hasCompletedOnboarding"
    
    private init() {
        // Load global stats
        if let data = UserDefaults.standard.data(forKey: globalStatsKey),
           let decoded = try? JSONDecoder().decode(GlobalStats.self, from: data) {
            self.globalStats = decoded
        } else {
            self.globalStats = GlobalStats()
        }
        
        // Load game stats
        if let data = UserDefaults.standard.data(forKey: gameStatsKey),
           let decoded = try? JSONDecoder().decode([GameType: GameStats].self, from: data) {
            self.gameStats = decoded
        } else {
            self.gameStats = Dictionary(uniqueKeysWithValues: GameType.allCases.map { ($0, GameStats()) })
        }
        
        // Load onboarding flag
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
    }
    
    func recordGameResult(gameType: GameType, score: Int, glowShardsEarned: Int, currentStreak: Int) {
        // Update game-specific stats
        var stats = gameStats[gameType] ?? GameStats()
        stats.totalPlays += 1
        if score > stats.bestScore {
            stats.bestScore = score
        }
        if currentStreak > stats.bestStreak {
            stats.bestStreak = currentStreak
        }
        gameStats[gameType] = stats
        
        // Update global stats
        globalStats.totalGlowShards += glowShardsEarned
        globalStats.totalRoutesPlayed += 1
        if currentStreak > globalStats.longestStreakOverall {
            globalStats.longestStreakOverall = currentStreak
        }
        
        saveAll()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
    }
    
    func resetAllProgress() {
        globalStats = GlobalStats()
        gameStats = Dictionary(uniqueKeysWithValues: GameType.allCases.map { ($0, GameStats()) })
        saveAll()
    }
    
    private func saveAll() {
        // Save global stats
        if let encoded = try? JSONEncoder().encode(globalStats) {
            UserDefaults.standard.set(encoded, forKey: globalStatsKey)
        }
        
        // Save game stats
        if let encoded = try? JSONEncoder().encode(gameStats) {
            UserDefaults.standard.set(encoded, forKey: gameStatsKey)
        }
    }
}

