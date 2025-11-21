//
//  LaneDashGameView.swift
//  DF742
//

import SwiftUI

struct LaneDashGameView: View {
    @ObservedObject var statsManager = StatsManager.shared
    @Environment(\.dismiss) var dismiss
    
    @State private var isPlaying = false
    @State private var markerPosition: CGFloat = 0.0
    @State private var markerSpeed: Double = 1.0
    @State private var safeZoneStart: CGFloat = 0.3
    @State private var safeZoneEnd: CGFloat = 0.5
    @State private var score = 0
    @State private var round = 0
    @State private var currentStreak = 0
    @State private var showResult = false
    @State private var roundScore = 0
    @State private var totalScore = 0
    @State private var glowShardsEarned = 0
    @State private var animationId = UUID()
    @State private var roundResultText: String? = nil
    @State private var canTap = false
    @State private var animationTimer: Timer?
    @State private var markerDirection: CGFloat = 1.0
    @State private var animationStartTime: Date?
    
    let maxRounds = 8
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Lane Dash")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Tap to stop the marker in the glow zone")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if !isPlaying && !showResult {
                        // Start screen
                        StartCard(onStart: startGame)
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
                            
                            if let result = roundResultText {
                                Text(result)
                                    .font(.headline)
                                    .foregroundColor(result.contains("+") ? Color.green : Color.red)
                                    .transition(.scale)
                            }
                            
                            // Lane with marker
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background lane
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("AccentIndigo"))
                                        .frame(height: 60)
                                    
                                    // Safe zone
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("AccentGold").opacity(0.3))
                                        .frame(
                                            width: geometry.size.width * (safeZoneEnd - safeZoneStart),
                                            height: 44
                                        )
                                        .offset(x: geometry.size.width * safeZoneStart + 8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color("AccentGold"), lineWidth: 2)
                                                .frame(
                                                    width: geometry.size.width * (safeZoneEnd - safeZoneStart),
                                                    height: 44
                                                )
                                                .offset(x: geometry.size.width * safeZoneStart + 8)
                                        )
                                    
                                    // Moving marker
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 30, height: 30)
                                        .shadow(color: Color.white.opacity(0.6), radius: 8)
                                        .offset(x: markerPosition * (geometry.size.width - 30))
                                }
                                .padding(.horizontal, 20)
                            }
                            .frame(height: 60)
                            .padding(.vertical, 40)
                            
                            // Tap button
                            Button(action: {
                                if canTap {
                                    stopMarker()
                                }
                            }) {
                                Text(canTap ? "TAP TO STOP" : "WAIT...")
                                    .font(.headline)
                                    .foregroundColor(Color("PrimaryBackground"))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(canTap ? Color("AccentGold") : Color("AccentIndigoSoft"))
                                    .cornerRadius(16)
                            }
                            .disabled(!canTap)
                            .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                    } else if showResult {
                        // Result screen
                        GameResultView(
                            gameType: .laneDash,
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
        markerPosition = 0.0
        markerDirection = 1.0
        markerSpeed = 1.0 + Double(round) * 0.2
        roundResultText = nil
        canTap = false
        
        // Randomize safe zone
        let zoneWidth = CGFloat.random(in: 0.15...0.25)
        safeZoneStart = CGFloat.random(in: 0.2...(0.8 - zoneWidth))
        safeZoneEnd = safeZoneStart + zoneWidth
        
        // Start animation after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.isPlaying {
                self.startMarkerAnimation()
            }
        }
    }
    
    private func startMarkerAnimation() {
        canTap = true
        animationStartTime = Date()
        
        // Stop any existing timer
        animationTimer?.invalidate()
        
        // Create new timer for smooth animation
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [self] timer in
            guard self.canTap else {
                timer.invalidate()
                return
            }
            
            // Update position
            let speed = CGFloat(self.markerSpeed) * 0.01
            markerPosition += markerDirection * speed
            
            // Reverse direction at edges
            if markerPosition >= 1.0 {
                markerPosition = 1.0
                markerDirection = -1.0
            } else if markerPosition <= 0.0 {
                markerPosition = 0.0
                markerDirection = 1.0
            }
        }
    }
    
    private func stopMarker() {
        guard canTap else { return }
        
        // Stop animation immediately
        canTap = false
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Current position is already captured in markerPosition state
        let capturedPosition = markerPosition
        
        // Calculate score based on captured position
        if capturedPosition >= safeZoneStart && capturedPosition <= safeZoneEnd {
            let center = (safeZoneStart + safeZoneEnd) / 2
            let distance = abs(capturedPosition - center)
            let maxDistance = (safeZoneEnd - safeZoneStart) / 2
            let accuracy = 1.0 - (distance / maxDistance)
            roundScore = Int(accuracy * 100)
            currentStreak += 1
            
            withAnimation {
                roundResultText = "Hit! +\(roundScore)"
            }
        } else {
            roundScore = 0
            currentStreak = 0
            
            withAnimation {
                roundResultText = "Missed!"
            }
        }
        
        totalScore += roundScore
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            if round < maxRounds {
                round += 1
                startRound()
            } else {
                endGame()
            }
        }
    }
    
    private func endGame() {
        animationTimer?.invalidate()
        animationTimer = nil
        isPlaying = false
        showResult = true
        
        glowShardsEarned = totalScore / 10 + currentStreak * 2
        statsManager.recordGameResult(
            gameType: .laneDash,
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

struct StartCard: View {
    let onStart: () -> Void
    @ObservedObject var statsManager = StatsManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Image(systemName: "minus.forwardslash.plus")
                    .font(.system(size: 44))
                    .foregroundColor(Color("AccentGold"))
                
                Text("Ready to Start?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Watch the marker move along the lane. Tap to stop it inside the glowing zone for maximum points!")
                    .font(.body)
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 16)
            
            if let stats = statsManager.gameStats[.laneDash], stats.bestScore > 0 {
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

