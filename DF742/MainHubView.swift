//
//  MainHubView.swift
//  DF742
//

import SwiftUI

struct MainHubView: View {
    @ObservedObject var statsManager = StatsManager.shared
    @State private var showSettings = false
    @State private var selectedGame: GameType?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Top section - Today's Route card
                        TodaysRouteCard()
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        
                        // Mini-games grid
                        VStack(spacing: 16) {
                            ForEach(GameType.allCases, id: \.self) { gameType in
                                GameCard(gameType: gameType)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                
                NavigationLink(
                    destination: selectedGame.map { GameViewRouter(gameType: $0) },
                    isActive: Binding(
                        get: { selectedGame != nil },
                        set: { if !$0 { selectedGame = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
                
                NavigationLink(destination: SettingsStatsView(), isActive: $showSettings) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color("AccentGold"))
                            .font(.title3)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct TodaysRouteCard: View {
    @ObservedObject var statsManager = StatsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Your Route")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Pick any route below to train your focus and reaction")
                .font(.subheadline)
                .foregroundColor(Color.white.opacity(0.7))
            
            Divider()
                .background(Color("AccentIndigoSoft"))
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color("AccentGold"))
                            .font(.caption)
                        Text("Glow Shards")
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    Text("\(statsManager.globalStats.totalGlowShards)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(Color("AccentGold"))
                            .font(.caption)
                        Text("Longest Streak")
                            .font(.caption)
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    Text("\(statsManager.globalStats.longestStreakOverall)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color("CardBackground"))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct GameCard: View {
    let gameType: GameType
    @ObservedObject var statsManager = StatsManager.shared
    @State private var isPressed = false
    
    var body: some View {
        NavigationLink(destination: GameViewRouter(gameType: gameType)) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("AccentIndigo"))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: gameType.iconName)
                        .font(.title2)
                        .foregroundColor(Color("AccentGold"))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(gameType.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(gameType.description)
                        .font(.caption)
                        .foregroundColor(Color.white.opacity(0.6))
                        .lineLimit(1)
                    
                    if let stats = statsManager.gameStats[gameType] {
                        HStack(spacing: 8) {
                            Label("\(stats.bestScore)", systemImage: "trophy.fill")
                                .font(.caption2)
                                .foregroundColor(Color("AccentGoldSoft"))
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("AccentGoldSoft"))
                    .font(.caption)
            }
            .padding(16)
            .background(Color("CardBackground"))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
            .scaleEffect(isPressed ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

struct GameViewRouter: View {
    let gameType: GameType
    
    var body: some View {
        Group {
            switch gameType {
            case .laneDash:
                LaneDashGameView()
            case .signalFlow:
                SignalFlowGameView()
            case .crosswaySplit:
                CrosswaySplitGameView()
            case .timingArcs:
                TimingArcsGameView()
            }
        }
    }
}

