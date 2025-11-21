//
//  Models.swift
//  DF742
//

import Foundation

enum GameType: String, CaseIterable, Codable {
    case laneDash = "Lane Dash"
    case signalFlow = "Signal Flow"
    case crosswaySplit = "Crossway Split"
    case timingArcs = "Timing Arcs"
    
    var description: String {
        switch self {
        case .laneDash:
            return "Stop in the glow zone"
        case .signalFlow:
            return "Follow the signal pattern"
        case .crosswaySplit:
            return "Choose the safe lane"
        case .timingArcs:
            return "Time the perfect arc"
        }
    }
    
    var iconName: String {
        switch self {
        case .laneDash:
            return "minus.forwardslash.plus"
        case .signalFlow:
            return "light.beacon.max.fill"
        case .crosswaySplit:
            return "arrow.triangle.branch"
        case .timingArcs:
            return "circle.dotted.circle"
        }
    }
}

struct GameStats: Codable {
    var bestScore: Int
    var totalPlays: Int
    var bestStreak: Int
    
    init() {
        self.bestScore = 0
        self.totalPlays = 0
        self.bestStreak = 0
    }
}

struct GlobalStats: Codable {
    var totalGlowShards: Int
    var totalRoutesPlayed: Int
    var longestStreakOverall: Int
    
    init() {
        self.totalGlowShards = 0
        self.totalRoutesPlayed = 0
        self.longestStreakOverall = 0
    }
}


