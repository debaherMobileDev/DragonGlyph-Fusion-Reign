//
//  DragonLairMainView.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import SwiftUI

struct DragonLairMainView: View {
    @StateObject private var viewModel = DragonHeartViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var showCodex = false
    @State private var showChronicle = false
    @State private var showTome = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                .environmentObject(viewModel)
        } else {
            mainGameView
                .environmentObject(viewModel)
        }
    }
    
    private var mainGameView: some View {
        ZStack {
            // Background
            Color(hex: "#0A0A12")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                
                // Dragon Heart Stats
                dragonHeartStats
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                
                // Chambers List
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.chambers) { chamber in
                            ChamberCard(chamber: chamber)
                                .onTapGesture {
                                    if chamber.isUnlocked {
                                        viewModel.selectChamber(chamber)
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            
            // Modals
            if viewModel.showChamber, let chamber = viewModel.selectedChamber {
                LairChamberView(chamber: chamber, difficulty: chamber.difficulty)
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showCodex) {
            DragonCodexView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showChronicle) {
            KeepersChronicleView()
        }
        .sheet(isPresented: $showTome) {
            KeepersTomeView()
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            // Left: Menu Buttons
            HStack(spacing: 12) {
                Button(action: { showCodex = true }) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#00E0FF"))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "#2A2A3E"))
                        .clipShape(Circle())
                }
                
                Button(action: { showChronicle = true }) {
                    Image(systemName: "scroll.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "#FFB347"))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "#2A2A3E"))
                        .clipShape(Circle())
                }
            }
            
            Spacer()
            
            // Center: Title
            VStack(spacing: 4) {
                Text("Dragon's Lair")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("Fusion Reign")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "#FF4D00"))
            }
            
            Spacer()
            
            // Right: Settings
            Button(action: { showTome = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "#FF4D00"))
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "#2A2A3E"))
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Dragon Heart Stats
    private var dragonHeartStats: some View {
        VStack(spacing: 16) {
            // Dragon State
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#FF4D00"))
                    .scaleEffect(viewModel.heartPulseAnimation ? 1.2 : 1.0)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.playerProgress.dragonState.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("Dragon State")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "#FF4D00").opacity(0.2),
                        Color(hex: "#2A2A3E")
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            
            // Stats Grid
            HStack(spacing: 12) {
                StatCard(
                    icon: "star.fill",
                    title: "Score",
                    value: "\(viewModel.playerProgress.totalScore)",
                    color: Color(hex: "#FFB347")
                )
                
                StatCard(
                    icon: "bolt.fill",
                    title: "Energy",
                    value: "\(viewModel.playerProgress.totalEnergy)",
                    color: Color(hex: "#00E0FF")
                )
                
                StatCard(
                    icon: "checkmark.seal.fill",
                    title: "Complete",
                    value: "\(viewModel.playerProgress.chambersCompleted)",
                    color: Color(hex: "#3cc45b")
                )
            }
        }
    }
}

// MARK: - Supporting Views
struct ChamberCard: View {
    let chamber: LairChamber
    
    var body: some View {
        HStack(spacing: 16) {
            // Chamber Number
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                chamber.themeColor.opacity(0.3),
                                chamber.themeColor.opacity(0.1)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Text("\(chamber.chamberNumber)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(chamber.isUnlocked ? chamber.themeColor : Color.white.opacity(0.3))
            }
            
            // Chamber Info
            VStack(alignment: .leading, spacing: 6) {
                Text(chamber.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(chamber.isUnlocked ? .white : Color.white.opacity(0.5))
                
                HStack(spacing: 12) {
                    Label("\(chamber.gridSize)x\(chamber.gridSize)", systemImage: "square.grid.3x3")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                    
                    Label(chamber.difficulty.rawValue, systemImage: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(chamber.themeColor)
                }
                
                if chamber.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#FFB347"))
                        Text("Best: \(chamber.bestScore)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#FFB347"))
                    }
                }
            }
            
            Spacer()
            
            // Status Icon
            if !chamber.isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white.opacity(0.3))
            } else if chamber.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#3cc45b"))
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "#FF4D00"))
            }
        }
        .padding(16)
        .background(Color(hex: "#2A2A3E"))
        .cornerRadius(15)
        .opacity(chamber.isUnlocked ? 1.0 : 0.6)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(hex: "#2A2A3E"))
        .cornerRadius(12)
    }
}


