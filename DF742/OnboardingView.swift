//
//  OnboardingView.swift
//  DF742
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("PrimaryBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Main content area with TabView
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
                    
                    // Bottom buttons - fixed height
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
                                .frame(height: 50)
                                .background(Color("AccentGold"))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundColor(Color("AccentGoldSoft"))
                                .frame(height: 44)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom, 16))
                    .background(Color("PrimaryBackground"))
                }
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
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Illustration
                    ZStack {
                        // Background glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color("AccentGold").opacity(0.3), Color.clear],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .opacity(pulseAnimation ? 0.5 : 0.8)
                        
                        // Crossway lanes
                        VStack(spacing: 6) {
                            ForEach(0..<3) { index in
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(Color("AccentIndigo"))
                                    .frame(width: 120, height: 10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 3)
                                            .stroke(Color("AccentGoldSoft"), lineWidth: 1.5)
                                    )
                            }
                        }
                        
                        // Glowing orb
                        Circle()
                            .fill(Color("AccentGold"))
                            .frame(width: 24, height: 24)
                            .shadow(color: Color("AccentGold").opacity(0.8), radius: 8)
                    }
                    .frame(height: min(geometry.size.height * 0.35, 200))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                            pulseAnimation = true
                        }
                    }
                    
                    // Text content
                    VStack(spacing: 12) {
                        Text("Enter the Night Roads")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Enter a world where glowing lanes and signals respond to your every move. Play focused mini-games in this stylized night intersection.")
                            .font(.body)
                            .foregroundColor(Color.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct OnboardingPage2View: View {
    @State private var animationOffset: CGFloat = -80
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Illustration
                    ZStack {
                        // Multiple lanes with moving dots
                        HStack(spacing: 16) {
                            ForEach(0..<3) { index in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color("AccentIndigo"))
                                    .frame(width: 50, height: 160)
                                    .overlay(
                                        Circle()
                                            .fill(Color("AccentGold"))
                                            .frame(width: 16, height: 16)
                                            .offset(y: animationOffset + CGFloat(index * 25))
                                            .shadow(color: Color("AccentGold"), radius: 6)
                                    )
                                    .clipped()
                            }
                        }
                    }
                    .frame(height: min(geometry.size.height * 0.35, 200))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .onAppear {
                        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                            animationOffset = 80
                        }
                    }
                    
                    // Text content
                    VStack(spacing: 12) {
                        Text("Train Focus Through Fast Choices")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("Each mini-game challenges your reaction time, timing precision, and decision-making skills in quick, engaging rounds.")
                            .font(.body)
                            .foregroundColor(Color.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct OnboardingPage3View: View {
    @State private var showStats = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 24) {
                    // Illustration - Stats display
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            StatBadgeView(icon: "sparkles", value: "0", label: "Shards")
                            StatBadgeView(icon: "star.fill", value: "0", label: "Streak")
                        }
                        
                        HStack(spacing: 12) {
                            StatBadgeView(icon: "flag.fill", value: "0", label: "Routes")
                            StatBadgeView(icon: "chart.bar.fill", value: "0", label: "Best")
                        }
                    }
                    .opacity(showStats ? 1.0 : 0.0)
                    .scaleEffect(showStats ? 1.0 : 0.8)
                    .frame(height: min(geometry.size.height * 0.35, 200))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                            showStats = true
                        }
                    }
                    
                    // Text content
                    VStack(spacing: 12) {
                        Text("Track Your Routes and Progress")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Text("View your statistics, track your best scores across all games, and reset your progress whenever you want to start fresh.")
                            .font(.body)
                            .foregroundColor(Color.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
    }
}

struct StatBadgeView: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color("AccentGold"))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(Color.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color("CardBackground"))
        .cornerRadius(10)
    }
}
