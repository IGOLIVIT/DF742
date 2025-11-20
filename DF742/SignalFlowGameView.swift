//
//  SignalFlowGameView.swift
//  DF742
//

import SwiftUI

struct SignalFlowGameView: View {
    @ObservedObject var statsManager = StatsManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isPlaying = false
    @State private var showingSequence = false
    @State private var sequence: [Int] = []
    @State private var userSequence: [Int] = []
    @State private var activeLight: Int? = nil
    @State private var round = 0
    @State private var totalScore = 0
    @State private var currentStreak = 0
    @State private var showResult = false
    @State private var glowShardsEarned = 0
    @State private var isWaitingForInput = false
    @State private var roundResultText: String? = nil
    
    let gridSize = 9
    let maxRounds = 8
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Signal Flow")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Watch the signal pattern, then repeat it")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if !isPlaying && !showResult {
                        // Start screen
                        SignalFlowStartCard(onStart: startGame)
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
                            
                            if showingSequence {
                                Text("Watch carefully...")
                                    .font(.subheadline)
                                    .foregroundColor(Color("AccentGoldSoft"))
                            } else if isWaitingForInput {
                                Text("Now repeat the pattern")
                                    .font(.subheadline)
                                    .foregroundColor(Color("AccentGold"))
                            }
                            
                            if let result = roundResultText {
                                Text(result)
                                    .font(.headline)
                                    .foregroundColor(result.contains("Correct") ? Color.green : Color.red)
                                    .transition(.scale)
                            }
                            
                            // Signal grid
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                ForEach(0..<gridSize, id: \.self) { index in
                                    SignalLight(
                                        isActive: activeLight == index,
                                        index: index,
                                        isEnabled: isWaitingForInput
                                    ) {
                                        if isWaitingForInput {
                                            handleUserTap(index: index)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 40)
                            .padding(.vertical, 20)
                            
                            Spacer()
                        }
                    } else if showResult {
                        // Result screen
                        GameResultView(
                            gameType: .signalFlow,
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
        userSequence = []
        sequence = generateSequence(length: min(3 + round, 7))
        showingSequence = true
        isWaitingForInput = false
        roundResultText = nil
        playSequence()
    }
    
    private func generateSequence(length: Int) -> [Int] {
        var seq: [Int] = []
        for _ in 0..<length {
            seq.append(Int.random(in: 0..<gridSize))
        }
        return seq
    }
    
    private func playSequence() {
        var delay: Double = 0.0
        for light in sequence {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    activeLight = light
                }
            }
            delay += 0.6
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation {
                    activeLight = nil
                }
            }
            delay += 0.2
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.5) {
            showingSequence = false
            isWaitingForInput = true
        }
    }
    
    private func handleUserTap(index: Int) {
        userSequence.append(index)
        
        // Flash the light
        withAnimation {
            activeLight = index
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                activeLight = nil
            }
        }
        
        // Check if correct
        if userSequence.count <= sequence.count {
            if userSequence[userSequence.count - 1] != sequence[userSequence.count - 1] {
                // Wrong
                handleRoundEnd(success: false)
                return
            }
            
            if userSequence.count == sequence.count {
                // Completed successfully
                handleRoundEnd(success: true)
            }
        }
    }
    
    private func handleRoundEnd(success: Bool) {
        isWaitingForInput = false
        
        if success {
            let roundScore = 100 + sequence.count * 10
            totalScore += roundScore
            currentStreak += 1
            
            withAnimation {
                roundResultText = "Correct! +\(roundScore)"
            }
        } else {
            currentStreak = 0
            
            withAnimation {
                roundResultText = "Wrong pattern!"
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
            gameType: .signalFlow,
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

struct SignalLight: View {
    let isActive: Bool
    let index: Int
    let isEnabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Circle()
                .fill(isActive ? Color("AccentGold") : Color("AccentIndigo"))
                .frame(height: 70)
                .overlay(
                    Circle()
                        .stroke(isActive ? Color("AccentGold") : Color("AccentIndigoSoft"), lineWidth: 2)
                )
                .shadow(color: isActive ? Color("AccentGold").opacity(0.8) : Color.clear, radius: 12)
                .scaleEffect(isActive ? 1.1 : 1.0)
        }
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

struct SignalFlowStartCard: View {
    let onStart: () -> Void
    @ObservedObject var statsManager = StatsManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "light.beacon.max.fill")
                    .font(.system(size: 48))
                    .foregroundColor(Color("AccentGold"))
                
                Text("Ready to Start?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Watch the lights flash in sequence, then tap them back in the same order. The sequence gets longer each round!")
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 20)
            
            if let stats = statsManager.gameStats[.signalFlow], stats.bestScore > 0 {
                VStack(spacing: 8) {
                    Text("Your Best Score")
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                    Text("\(stats.bestScore)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color("AccentGold"))
                }
                .padding(.vertical, 12)
            }
            
            Button(action: onStart) {
                Text("Start Game")
                    .font(.headline)
                    .foregroundColor(Color("PrimaryBackground"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color("AccentGold"))
                    .cornerRadius(16)
            }
            .padding(.bottom, 20)
        }
        .padding(24)
        .background(Color("CardBackground"))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

