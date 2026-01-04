//
//  ContentView.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: DragonHeartViewModel
    @State private var showCodex = false
    @State private var showChronicle = false
    @State private var showTome = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "#0A0A12")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            // Dragon's Heart
                            dragonHeartSection
                            
                            // Progress Stats
                            progressStatsSection
                            
                            // Chambers Grid
                            chambersSection
                            
                            // Spacer at bottom
                            Color.clear.frame(height: 20)
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarHidden(true)
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
            .sheet(item: $viewModel.selectedChamber) { chamber in
                LairChamberView(chamber: chamber, difficulty: viewModel.settings.currentDifficulty)
                    .environmentObject(viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Text("Dragon's Lair")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            HStack(spacing: 12) {
                MenuButton(icon: "book.fill", color: Color(hex: "#00E0FF")) {
                    showCodex = true
                }
                
                MenuButton(icon: "scroll.fill", color: Color(hex: "#FFB347")) {
                    showChronicle = true
                }
                
                MenuButton(icon: "gearshape.fill", color: Color(hex: "#2A2A3E")) {
                    showTome = true
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 20)
    }
    
    // MARK: - Dragon's Heart
    private var dragonHeartSection: some View {
        VStack(spacing: 16) {
            Text("The Dragon's Heart")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#FFB347"))
            
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                viewModel.playerProgress.dragonState.heartColor.opacity(0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(viewModel.heartPulseAnimation ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: viewModel.heartPulseAnimation)
                
                // Heart
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                viewModel.playerProgress.dragonState.heartColor,
                                viewModel.playerProgress.dragonState.heartColor.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // Heart icon
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
            .padding(.vertical, 20)
            
            // Dragon State
            VStack(spacing: 8) {
                Text(viewModel.playerProgress.dragonState.rawValue)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(viewModel.playerProgress.dragonState.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "#2A2A3E"))
        )
    }
    
    // MARK: - Progress Stats
    private var progressStatsSection: some View {
        HStack(spacing: 12) {
            ProgressStat(
                icon: "flame.fill",
                title: "Energy",
                value: "\(viewModel.playerProgress.totalEnergy)",
                color: Color(hex: "#FF4D00")
            )
            
            ProgressStat(
                icon: "star.fill",
                title: "Score",
                value: "\(viewModel.playerProgress.totalScore)",
                color: Color(hex: "#FFB347")
            )
            
            ProgressStat(
                icon: "building.columns.fill",
                title: "Chambers",
                value: "\(viewModel.playerProgress.chambersCompleted)",
                color: Color(hex: "#00E0FF")
            )
        }
    }
    
    // MARK: - Chambers
    private var chambersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lair Chambers")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(viewModel.chambers) { chamber in
                    ChamberCard(chamber: chamber) {
                        if chamber.isUnlocked {
                            viewModel.selectChamber(chamber)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views
struct MenuButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())
        }
    }
}

struct ProgressStat: View {
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
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(hex: "#2A2A3E"))
        .cornerRadius(12)
    }
}

struct ChamberCard: View {
    let chamber: LairChamber
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Chamber number badge
                HStack {
                    Text("\(chamber.chamberNumber)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(chamber.themeColor)
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    if chamber.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#FFB347"))
                    } else if !chamber.isUnlocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color.white.opacity(0.4))
                    }
                }
                
                // Chamber name
                Text(chamber.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(chamber.isUnlocked ? .white : Color.white.opacity(0.4))
                    .lineLimit(2)
                    .frame(height: 36, alignment: .topLeading)
                
                // Stats
                if chamber.isUnlocked {
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.system(size: 10))
                            Text("\(chamber.targetScore)")
                                .font(.system(size: 11, weight: .medium))
                        }
                        
                        if chamber.bestScore > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 10))
                                Text("\(chamber.bestScore)")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(Color(hex: "#FFB347"))
                        }
                    }
                    .foregroundColor(Color.white.opacity(0.6))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                chamber.isUnlocked ?
                    Color(hex: "#2A2A3E") :
                    Color(hex: "#2A2A3E").opacity(0.5)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        chamber.isCompleted ? Color(hex: "#FFB347") : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .disabled(!chamber.isUnlocked)
    }
}

#Preview {
    ContentView()
        .environmentObject(DragonHeartViewModel())
}
