//
//  GameResultView.swift
//  DF742
//

import SwiftUI

struct GameResultView: View {
    let gameType: GameType
    let totalScore: Int
    let glowShardsEarned: Int
    let currentStreak: Int
    let onPlayAgain: () -> Void
    let onBackToHub: () -> Void
    
    @ObservedObject var statsManager = StatsManager.shared
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: gameType.iconName)
                    .font(.system(size: 60))
                    .foregroundColor(Color("AccentGold"))
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0.0)
                
                Text("Round Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Divider()
                    .background(Color("AccentIndigoSoft"))
                
                // Score details
                VStack(spacing: 16) {
                    ScoreRow(label: "Your Score", value: "\(totalScore)", isHighlight: true)
                    
                    if let stats = statsManager.gameStats[gameType] {
                        ScoreRow(label: "Best Score", value: "\(stats.bestScore)", isHighlight: false)
                    }
                    
                    ScoreRow(label: "Glow Shards Earned", value: "+\(glowShardsEarned)", isHighlight: false)
                    ScoreRow(label: "Current Streak", value: "\(currentStreak)", isHighlight: false)
                }
            }
            .padding(24)
            .background(Color("CardBackground"))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            .opacity(showContent ? 1.0 : 0.0)
            .offset(y: showContent ? 0 : 20)
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: onPlayAgain) {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundColor(Color("PrimaryBackground"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color("AccentGold"))
                        .cornerRadius(16)
                }
                
                Button(action: onBackToHub) {
                    Text("Back to Hub")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color("AccentIndigo"))
                        .cornerRadius(16)
                }
            }
            .opacity(showContent ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                showContent = true
            }
        }
    }
}

struct ScoreRow: View {
    let label: String
    let value: String
    let isHighlight: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(isHighlight ? .title2 : .headline)
                .fontWeight(isHighlight ? .bold : .semibold)
                .foregroundColor(isHighlight ? Color("AccentGold") : Color("AccentGoldSoft"))
        }
    }
}


