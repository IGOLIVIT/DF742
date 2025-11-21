//
//  CrosswaySplitGameView.swift
//  DF742
//

import SwiftUI

struct CrosswaySplitGameView: View {
    @ObservedObject var statsManager = StatsManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isPlaying = false
    @State private var lanes: [Lane] = []
    @State private var selectedLane: Int? = nil
    @State private var isAnimating = false
    @State private var round = 0
    @State private var totalScore = 0
    @State private var currentStreak = 0
    @State private var showResult = false
    @State private var glowShardsEarned = 0
    @State private var roundResult: String? = nil
    @State private var animationOffset: CGFloat = 0
    
    let maxRounds = 8
    let laneCount = 3
    
    struct Lane {
        var segments: [Bool] // true = safe, false = blocked
    }
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Crossway Split")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Pick the lane with safe glow segments")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if !isPlaying && !showResult {
                        // Start screen
                        CrosswaySplitStartCard(onStart: startGame)
                            .padding(.horizontal, 20)
                    } else if isPlaying {
                        // Game screen
                        VStack(spacing: 24) {
                            // Round info
                            HStack {
                                Text("Round \(round)/\(maxRounds)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Score: \(totalScore)")
                                    .font(.headline)
                                    .foregroundColor(Color("AccentGold"))
                            }
                            .padding(.horizontal, 20)
                            
                            if let result = roundResult {
                                Text(result)
                                    .font(.headline)
                                    .foregroundColor(result.contains("Safe") ? Color.green : Color.red)
                                    .transition(.scale)
                            }
                            
                            // Lanes
                            GeometryReader { geometry in
                                HStack(spacing: 16) {
                                    ForEach(0..<laneCount, id: \.self) { index in
                                        LaneView(
                                            lane: lanes.indices.contains(index) ? lanes[index] : Lane(segments: []),
                                            isSelected: selectedLane == index,
                                            animationOffset: animationOffset,
                                            onSelect: {
                                                if !isAnimating && selectedLane == nil {
                                                    selectLane(index: index)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .frame(height: min(350, UIScreen.main.bounds.height * 0.4))
                            
                            if selectedLane == nil && !isAnimating {
                                Text("Choose a lane before time runs out!")
                                    .font(.subheadline)
                                    .foregroundColor(Color("AccentGoldSoft"))
                                    .transition(.opacity)
                            }
                            
                            Spacer()
                        }
                    } else if showResult {
                        // Result screen
                        GameResultView(
                            gameType: .crosswaySplit,
                            totalScore: totalScore,
                            glowShardsEarned: glowShardsEarned,
                            currentStreak: currentStreak,
                            onPlayAgain: resetGame,
                            onBackToHub: { dismiss() }
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func startGame() {
        round = 1
        totalScore = 0
        currentStreak = 0
        isPlaying = true
        startRound()
    }
    
    private func startRound() {
        selectedLane = nil
        isAnimating = false
        roundResult = nil
        animationOffset = 0
        
        // Generate lanes
        lanes = (0..<laneCount).map { _ in
            let segmentCount = 6
            var segments: [Bool] = []
            for _ in 0..<segmentCount {
                segments.append(Bool.random())
            }
            // Ensure at least one lane has a safe ending
            return Lane(segments: segments)
        }
        
        // Ensure at least one lane ends safely
        if !lanes.contains(where: { $0.segments.last == true }) {
            let randomLane = Int.random(in: 0..<laneCount)
            lanes[randomLane].segments[lanes[randomLane].segments.count - 1] = true
        }
        
        // Auto-select after delay if user doesn't choose
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if selectedLane == nil && isPlaying && !isAnimating {
                selectLane(index: Int.random(in: 0..<laneCount))
            }
        }
    }
    
    private func selectLane(index: Int) {
        selectedLane = index
        isAnimating = true
        
        withAnimation(.linear(duration: 1.5)) {
            animationOffset = -400
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            evaluateChoice()
        }
    }
    
    private func evaluateChoice() {
        guard let selected = selectedLane, selected < lanes.count else { return }
        
        let isSafe = lanes[selected].segments.last == true
        
        withAnimation {
            if isSafe {
                roundResult = "Safe Lane! +100"
                totalScore += 100
                currentStreak += 1
            } else {
                roundResult = "Blocked! No points"
                currentStreak = 0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if round < maxRounds {
                round += 1
                startRound()
            } else {
                endGame()
            }
        }
    }
    
    private func endGame() {
        isPlaying = false
        showResult = true
        
        glowShardsEarned = totalScore / 10 + currentStreak * 2
        statsManager.recordGameResult(
            gameType: .crosswaySplit,
            score: totalScore,
            glowShardsEarned: glowShardsEarned,
            currentStreak: currentStreak
        )
    }
    
    private func resetGame() {
        showResult = false
        startGame()
    }
}

struct LaneView: View {
    let lane: CrosswaySplitGameView.Lane
    let isSelected: Bool
    let animationOffset: CGFloat
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("AccentIndigo"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color("AccentGold") : Color("AccentIndigoSoft"), lineWidth: isSelected ? 3 : 1)
                    )
                
                VStack(spacing: 8) {
                    ForEach(0..<lane.segments.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(lane.segments[index] ? Color("AccentGold").opacity(0.6) : Color("PrimaryBackground"))
                            .frame(height: 45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(lane.segments[index] ? Color("AccentGold") : Color.clear, lineWidth: 1)
                            )
                    }
                }
                .padding(8)
                .offset(y: animationOffset)
                .clipped()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CrosswaySplitStartCard: View {
    let onStart: () -> Void
    @ObservedObject var statsManager = StatsManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.system(size: 44))
                    .foregroundColor(Color("AccentGold"))
                
                Text("Ready to Start?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Three lanes scroll downward. Pick the lane that ends in a safe glowing segment to score points!")
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 16)
            
            if let stats = statsManager.gameStats[.crosswaySplit], stats.bestScore > 0 {
                VStack(spacing: 6) {
                    Text("Your Best Score")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                    Text("\(stats.bestScore)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentGold"))
                }
                .padding(.vertical, 8)
            }
            
            Button(action: onStart) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(Color("PrimaryBackground"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color("AccentGold"))
                    .cornerRadius(12)
            }
            .padding(.bottom, 16)
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

