//
//  TimingArcsGameView.swift
//  DF742
//

import SwiftUI

struct TimingArcsGameView: View {
    @ObservedObject var statsManager = StatsManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isPlaying = false
    @State private var rotation: Double = 0
    @State private var safeArcStart: Double = 45
    @State private var safeArcEnd: Double = 135
    @State private var round = 0
    @State private var totalScore = 0
    @State private var currentStreak = 0
    @State private var showResult = false
    @State private var glowShardsEarned = 0
    @State private var isRotating = false
    @State private var roundScore = 0
    @State private var roundFeedback: String? = nil
    @State private var canTap = false
    @State private var rotationTimer: Timer?
    @State private var rotationSpeed: Double = 0.0
    
    let maxRounds = 8
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Timing Arcs")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Stop the pointer in the glowing arc")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if !isPlaying && !showResult {
                        // Start screen
                        TimingArcsStartCard(onStart: startGame)
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
                            
                            if let feedback = roundFeedback {
                                Text(feedback)
                                    .font(.headline)
                                    .foregroundColor(Color("AccentGoldSoft"))
                                    .transition(.scale)
                            }
                            
                            // Circular arc with rotating pointer
                            ZStack {
                                // Base circle
                                Circle()
                                    .stroke(Color("AccentIndigo"), lineWidth: 30)
                                    .frame(width: 250, height: 250)
                                
                                // Safe arc segment
                                Circle()
                                    .trim(from: safeArcStart / 360, to: safeArcEnd / 360)
                                    .stroke(Color("AccentGold"), lineWidth: 30)
                                    .frame(width: 250, height: 250)
                                    .rotationEffect(.degrees(-90))
                                    .shadow(color: Color("AccentGold").opacity(0.6), radius: 8)
                                
                                // Rotating pointer
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 4, height: 110)
                                    .offset(y: -55)
                                    .rotationEffect(.degrees(rotation))
                                    .shadow(color: Color.white.opacity(0.8), radius: 6)
                                
                                // Center dot
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 16, height: 16)
                            }
                            .padding(.vertical, 40)
                            
                            // Tap button
                            Button(action: {
                                if canTap && isRotating {
                                    stopPointer()
                                }
                            }) {
                                Text(canTap && isRotating ? "TAP TO STOP" : "WAIT...")
                                    .font(.headline)
                                    .foregroundColor(Color("PrimaryBackground"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background((canTap && isRotating) ? Color("AccentGold") : Color("AccentIndigoSoft"))
                                    .cornerRadius(16)
                            }
                            .disabled(!canTap || !isRotating)
                            .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                    } else if showResult {
                        // Result screen
                        GameResultView(
                            gameType: .timingArcs,
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
        rotation = 0
        roundFeedback = nil
        canTap = false
        isRotating = false
        
        // Randomize safe arc
        let arcWidth = Double.random(in: 40...70)
        safeArcStart = Double.random(in: 0...(360 - arcWidth))
        safeArcEnd = safeArcStart + arcWidth
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if self.isPlaying {
                self.startRotation()
            }
        }
    }
    
    private func startRotation() {
        isRotating = true
        canTap = true
        
        // Calculate speed - gets faster each round
        let baseDuration = 2.0 - Double(round) * 0.15
        rotationSpeed = 360.0 / (baseDuration * 60.0) // degrees per frame at 60fps
        
        // Stop any existing timer
        rotationTimer?.invalidate()
        
        // Create new timer for smooth rotation
        rotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [self] timer in
            guard self.canTap && self.isRotating else {
                timer.invalidate()
                return
            }
            
            // Update rotation
            rotation += rotationSpeed
            
            // Keep within 0-360 range
            if rotation >= 360 {
                rotation -= 360
            }
        }
    }
    
    private func stopPointer() {
        guard canTap && isRotating else { return }
        
        // Stop immediately
        canTap = false
        isRotating = false
        rotationTimer?.invalidate()
        rotationTimer = nil
        
        // Capture current rotation
        let capturedRotation = rotation.truncatingRemainder(dividingBy: 360)
        
        // Normalize angles for comparison
        let normalizedRotation = capturedRotation
        var normalizedStart = safeArcStart
        var normalizedEnd = safeArcEnd
        
        // Check if pointer is in safe arc
        let isInSafeZone: Bool
        if normalizedEnd > 360 {
            // Arc wraps around 0
            normalizedEnd -= 360
            isInSafeZone = normalizedRotation >= normalizedStart || normalizedRotation <= normalizedEnd
        } else {
            isInSafeZone = normalizedRotation >= normalizedStart && normalizedRotation <= normalizedEnd
        }
        
        if isInSafeZone {
            // Calculate accuracy
            let arcCenter = (safeArcStart + safeArcEnd) / 2
            let distance = min(abs(normalizedRotation - arcCenter), abs(normalizedRotation - arcCenter + 360), abs(normalizedRotation - arcCenter - 360))
            let maxDistance = (safeArcEnd - safeArcStart) / 2
            let accuracy = max(0, 1.0 - (distance / maxDistance))
            roundScore = Int(accuracy * 100)
            currentStreak += 1
            
            withAnimation {
                roundFeedback = "Hit! +\(roundScore)"
            }
        } else {
            roundScore = 0
            currentStreak = 0
            
            withAnimation {
                roundFeedback = "Missed!"
            }
        }
        
        totalScore += roundScore
        
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
        rotationTimer?.invalidate()
        rotationTimer = nil
        isPlaying = false
        showResult = true
        
        glowShardsEarned = totalScore / 10 + currentStreak * 2
        statsManager.recordGameResult(
            gameType: .timingArcs,
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

struct TimingArcsStartCard: View {
    let onStart: () -> Void
    @ObservedObject var statsManager = StatsManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "circle.dotted.circle")
                    .font(.system(size: 48))
                    .foregroundColor(Color("AccentGold"))
                
                Text("Ready to Start?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("A pointer rotates around the circle. Time your tap to stop it inside the glowing arc for maximum points!")
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 20)
            
            if let stats = statsManager.gameStats[.timingArcs], stats.bestScore > 0 {
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

