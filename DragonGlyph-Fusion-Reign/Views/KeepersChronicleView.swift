//
//  KeepersChronicleView.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import SwiftUI

struct KeepersChronicleView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var leaderboard: [LeaderboardEntry] = []
    
    private let persistenceService = LairPersistenceService.shared
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#0A0A12")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "#00E0FF"))
                            .frame(width: 40, height: 40)
                            .background(Color(hex: "#2A2A3E"))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text("Keeper's Chronicle")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text("Ranked by Dragon's Favor")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                // Leaderboard
                if leaderboard.isEmpty {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Image(systemName: "scroll")
                            .font(.system(size: 60))
                            .foregroundColor(Color(hex: "#2A2A3E"))
                        
                        Text("The Chronicle Awaits")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.white.opacity(0.7))
                        
                        Text("Complete chambers to etch your name in history.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(leaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRow(
                                    rank: index + 1,
                                    entry: entry
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .onAppear {
            loadLeaderboard()
        }
    }
    
    private func loadLeaderboard() {
        leaderboard = persistenceService.loadLeaderboard()
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "#FFB347")
        case 2: return Color(hex: "#C0C0C0")
        case 3: return Color(hex: "#CD7F32")
        default: return Color.white.opacity(0.6)
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "star.fill"
        case 3: return "star.fill"
        default: return "circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 2) {
                    Image(systemName: rankIcon)
                        .font(.system(size: rank <= 3 ? 16 : 8))
                        .foregroundColor(rankColor)
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(rankColor)
                }
            }
            
            // Player Info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#FF4D00"))
                        Text("\(entry.dragonFavor)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundColor(Color(hex: "#FFB347"))
                        Text("\(entry.score)")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Date
            Text(formatDate(entry.timestamp))
                .font(.system(size: 12))
                .foregroundColor(Color.white.opacity(0.5))
        }
        .padding(16)
        .background(Color(hex: "#2A2A3E"))
        .cornerRadius(12)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

