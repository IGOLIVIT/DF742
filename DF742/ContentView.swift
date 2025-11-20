//
//  ContentView.swift
//  DF742
//

import SwiftUI

struct ContentView: View {
    @StateObject private var statsManager = StatsManager.shared
    @State private var showOnboarding = false
    
    var body: some View {
        Group {
            if statsManager.hasCompletedOnboarding {
                MainHubView()
            } else {
                MainHubView()
                    .onAppear {
                        showOnboarding = true
                    }
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
        }
    }
}

#Preview {
    ContentView()
}
