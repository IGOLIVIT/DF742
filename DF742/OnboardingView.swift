//
//  OnboardingView.swift
//  DF742
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            Color("PrimaryBackground")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    OnboardingPage1View()
                        .tag(0)
                    OnboardingPage2View()
                        .tag(1)
                    OnboardingPage3View()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                
                // Bottom buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundColor(Color("PrimaryBackground"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color("AccentGold"))
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        completeOnboarding()
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(Color("AccentGoldSoft"))
                    }
                    .padding(.bottom, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }
    
    private func completeOnboarding() {
        StatsManager.shared.completeOnboarding()
        isPresented = false
    }
}

struct OnboardingPage1View: View {
    @State private var pulseAnimation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                
                // Illustration
                ZStack {
                    // Background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color("AccentGold").opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .opacity(pulseAnimation ? 0.5 : 0.8)
                    
                    // Crossway lanes
                    VStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("AccentIndigo"))
                                .frame(width: 150, height: 12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color("AccentGoldSoft"), lineWidth: 2)
                                )
                        }
                    }
                    
                    // Glowing orb
                    Circle()
                        .fill(Color("AccentGold"))
                        .frame(width: 30, height: 30)
                        .shadow(color: Color("AccentGold").opacity(0.8), radius: 10)
                }
                .frame(height: 250)
                .onAppear {
                    withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                        pulseAnimation = true
                    }
                }
                
                // Text content
                VStack(spacing: 16) {
                    Text("Enter the Night Roads")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Enter a world where glowing lanes and signals respond to your every move. Play focused mini-games in this stylized night intersection.")
                        .font(.body)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct OnboardingPage2View: View {
    @State private var animationOffset: CGFloat = -100
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                
                // Illustration
                ZStack {
                    // Multiple lanes with moving dots
                    HStack(spacing: 20) {
                        ForEach(0..<3) { index in
                            VStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("AccentIndigo"))
                                    .frame(width: 60, height: 200)
                                    .overlay(
                                        Circle()
                                            .fill(Color("AccentGold"))
                                            .frame(width: 20, height: 20)
                                            .offset(y: animationOffset + CGFloat(index * 30))
                                            .shadow(color: Color("AccentGold"), radius: 8)
                                    )
                                    .clipped()
                            }
                        }
                    }
                }
                .frame(height: 250)
                .onAppear {
                    withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                        animationOffset = 100
                    }
                }
                
                // Text content
                VStack(spacing: 16) {
                    Text("Train Focus Through Fast Choices")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Each mini-game challenges your reaction time, timing precision, and decision-making skills in quick, engaging rounds.")
                        .font(.body)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct OnboardingPage3View: View {
    @State private var showStats = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer(minLength: 40)
                
                // Illustration - Stats display
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        StatBadgeView(icon: "sparkles", value: "0", label: "Shards")
                        StatBadgeView(icon: "star.fill", value: "0", label: "Streak")
                    }
                    
                    HStack(spacing: 16) {
                        StatBadgeView(icon: "flag.fill", value: "0", label: "Routes")
                        StatBadgeView(icon: "chart.bar.fill", value: "0", label: "Best")
                    }
                }
                .opacity(showStats ? 1.0 : 0.0)
                .scaleEffect(showStats ? 1.0 : 0.8)
                .frame(height: 250)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                        showStats = true
                    }
                }
                
                // Text content
                VStack(spacing: 16) {
                    Text("Track Your Routes and Progress")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("View your statistics, track your best scores across all games, and reset your progress whenever you want to start fresh.")
                        .font(.body)
                        .foregroundColor(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 32)
                
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct StatBadgeView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color("AccentGold"))
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color("CardBackground"))
        .cornerRadius(12)
    }
}

