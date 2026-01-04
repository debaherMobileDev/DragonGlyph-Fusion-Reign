//
//  KeepersTomeView.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import SwiftUI

struct KeepersTomeView: View {
    @EnvironmentObject var viewModel: DragonHeartViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showResetAlert = false
    
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
                    
                    Text("Keeper's Tome")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Audio Settings
                        SettingsSection(title: "Lair Ambiance") {
                            SettingsToggle(
                                title: "Sound Effects",
                                icon: "speaker.wave.2.fill",
                                isOn: Binding(
                                    get: { viewModel.settings.soundEnabled },
                                    set: { newValue in
                                        var settings = viewModel.settings
                                        settings.soundEnabled = newValue
                                        viewModel.updateSettings(settings)
                                    }
                                )
                            )
                            
                            SettingsToggle(
                                title: "Dragon's Song",
                                icon: "music.note",
                                isOn: Binding(
                                    get: { viewModel.settings.musicEnabled },
                                    set: { newValue in
                                        var settings = viewModel.settings
                                        settings.musicEnabled = newValue
                                        viewModel.updateSettings(settings)
                                    }
                                )
                            )
                            
                            SettingsToggle(
                                title: "Haptic Feedback",
                                icon: "hand.tap.fill",
                                isOn: Binding(
                                    get: { viewModel.settings.hapticsEnabled },
                                    set: { newValue in
                                        var settings = viewModel.settings
                                        settings.hapticsEnabled = newValue
                                        viewModel.updateSettings(settings)
                                    }
                                )
                            )
                        }
                        
                        // Difficulty Settings
                        SettingsSection(title: "Challenge Level") {
                            VStack(spacing: 12) {
                                ForEach(Difficulty.allCases, id: \.self) { difficulty in
                                    DifficultyOption(
                                        difficulty: difficulty,
                                        isSelected: viewModel.settings.currentDifficulty == difficulty
                                    ) {
                                        var settings = viewModel.settings
                                        settings.currentDifficulty = difficulty
                                        viewModel.updateSettings(settings)
                                    }
                                }
                            }
                        }
                        
                        // Dragon Blessings Shop
                        SettingsSection(title: "Dragon's Blessings") {
                            VStack(spacing: 12) {
                                ForEach(viewModel.blessings) { blessing in
                                    BlessingShopItem(
                                        blessing: blessing,
                                        currentEnergy: viewModel.playerProgress.totalEnergy
                                    ) {
                                        _ = viewModel.purchaseBlessing(blessing)
                                    }
                                }
                            }
                        }
                        
                        // Reset Game
                        SettingsSection(title: "Keeper's Actions") {
                            Button(action: {
                                showResetAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "#FF4D00"))
                                    
                                    Text("Reset Game Progress")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color(hex: "#2A2A3E"))
                                .cornerRadius(12)
                            }
                        }
                        
                        // App Info
                        VStack(spacing: 8) {
                            Text("DragonGlyph: Fusion Reign")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.white.opacity(0.6))
                            Text("Session ID: 7582-DR")
                                .font(.system(size: 12))
                                .foregroundColor(Color.white.opacity(0.4))
                        }
                        .padding(.vertical, 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .alert(isPresented: $showResetAlert) {
            Alert(
                title: Text("Reset Game?"),
                message: Text("This will erase all progress, chambers, and blessings. Your leaderboard entries will be preserved."),
                primaryButton: .destructive(Text("Reset")) {
                    viewModel.resetGame()
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#FFB347"))
            
            content
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#00E0FF"))
                .frame(width: 30)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#FF4D00")))
        }
        .padding(16)
        .background(Color(hex: "#2A2A3E"))
        .cornerRadius(12)
    }
}

struct DifficultyOption: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Score x\(String(format: "%.1f", difficulty.scoreMultiplier))")
                        .font(.system(size: 12))
                        .foregroundColor(Color.white.opacity(0.6))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "#FFB347"))
                }
            }
            .padding(16)
            .background(isSelected ? Color(hex: "#FF4D00").opacity(0.2) : Color(hex: "#2A2A3E"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color(hex: "#FF4D00") : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct BlessingShopItem: View {
    let blessing: DragonBlessing
    let currentEnergy: Int
    let action: () -> Void
    
    private var canPurchase: Bool {
        currentEnergy >= blessing.cost
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: blessing.icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "#FFB347"))
                .frame(width: 40, height: 40)
                .background(Color(hex: "#FF4D00").opacity(0.2))
                .clipShape(Circle())
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(blessing.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Owned: \(blessing.count)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            
            Spacer()
            
            // Purchase Button
            Button(action: action) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                    Text("\(blessing.cost)")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(canPurchase ? Color(hex: "#FF4D00") : Color(hex: "#2A2A3E"))
                .cornerRadius(8)
            }
            .disabled(!canPurchase)
        }
        .padding(12)
        .background(Color(hex: "#2A2A3E"))
        .cornerRadius(12)
    }
}

