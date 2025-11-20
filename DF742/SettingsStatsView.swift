//
//  SettingsStatsView.swift
//  DF742
//

import SwiftUI

struct SettingsStatsView: View {
    @ObservedObject var statsManager = StatsManager.shared
    @State private var showResetConfirmation = false
    @State private var showOnboarding = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Stats Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Statistics")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        // Overall stats cards
                        VStack(spacing: 12) {
                            StatRow(icon: "sparkles", label: "Total Glow Shards", value: "\(statsManager.globalStats.totalGlowShards)")
                            StatRow(icon: "flag.fill", label: "Total Routes Played", value: "\(statsManager.globalStats.totalRoutesPlayed)")
                            StatRow(icon: "star.fill", label: "Best Streak", value: "\(statsManager.globalStats.longestStreakOverall)")
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    
                    // Per-game stats
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Best Scores by Game")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                if let stats = statsManager.gameStats[gameType] {
                                    GameStatCard(gameType: gameType, stats: stats)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Progress section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            InfoCard(text: "Your progress is stored locally on this device. You can reset all statistics and start fresh at any time.")
                            
                            Button(action: {
                                showResetConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset Progress")
                                        .fontWeight(.semibold)
                                }
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.red.opacity(0.8))
                                .cornerRadius(12)
                            }
                            
                            Button(action: {
                                showOnboarding = true
                            }) {
                                HStack {
                                    Image(systemName: "book.fill")
                                    Text("View Onboarding Again")
                                        .fontWeight(.semibold)
                                }
                                .font(.subheadline)
                                .foregroundColor(Color("PrimaryBackground"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color("AccentGoldSoft"))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Stats & Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Reset All Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                statsManager.resetAllProgress()
            }
        } message: {
            Text("This will clear all your statistics, best scores, and earned Glow Shards. This action cannot be undone.")
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color("AccentGold"))
                    .font(.title3)
                    .frame(width: 30)
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(Color("AccentGold"))
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }
}

struct GameStatCard: View {
    let gameType: GameType
    let stats: GameStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: gameType.iconName)
                    .foregroundColor(Color("AccentGold"))
                    .font(.title3)
                
                Text(gameType.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best Score")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                    Text("\(stats.bestScore)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AccentGoldSoft"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Plays")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                    Text("\(stats.totalPlays)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                    Text("\(stats.bestStreak)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }
}

struct InfoCard: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(Color("AccentGoldSoft"))
                .font(.title3)
            
            Text(text)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AccentIndigo"))
        .cornerRadius(12)
    }
}

