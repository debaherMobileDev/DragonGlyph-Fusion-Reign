//
//  LairChamberView.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import SwiftUI

struct LairChamberView: View {
    @StateObject var viewModel: GlyphPuzzleViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var dragonHeartViewModel: DragonHeartViewModel
    
    init(chamber: LairChamber, difficulty: Difficulty) {
        _viewModel = StateObject(wrappedValue: GlyphPuzzleViewModel(chamber: chamber, difficulty: difficulty))
    }
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#0A0A12")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                headerView
                
                // Game Stats
                statsView
                
                // Grid
                gameGridView
                    .padding(.horizontal, 20)
                
                // Blessings Bar
                blessingsBar
                
                Spacer()
            }
            
            // Game Over Overlay
            if viewModel.isGameOver {
                gameOverOverlay
            }
        }
        .onAppear {
            viewModel.startTimer()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#00E0FF"))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "#2A2A3E"))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(viewModel.chamber.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Text("Target: \(viewModel.chamber.targetScore)")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.6))
            }
            
            Spacer()
            
            Button(action: {
                viewModel.isPaused.toggle()
            }) {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "#FFB347"))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: "#2A2A3E"))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
    }
    
    // MARK: - Stats
    private var statsView: some View {
        HStack(spacing: 20) {
            StatBadge(title: "Score", value: "\(viewModel.score)", color: Color(hex: "#FF4D00"))
            StatBadge(title: "Energy", value: "\(viewModel.energy)", color: Color(hex: "#00E0FF"))
            StatBadge(title: "Time", value: formatTime(viewModel.timeRemaining), color: Color(hex: "#FFB347"))
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Game Grid
    private var gameGridView: some View {
        GeometryReader { geometry in
            let gridSize = viewModel.chamber.gridSize
            let cellSize = min(geometry.size.width, geometry.size.height) / CGFloat(gridSize) - 4
            
            VStack(spacing: 4) {
                ForEach(0..<gridSize, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(0..<gridSize, id: \.self) { col in
                            GlyphCell(
                                glyph: viewModel.grid[row][col],
                                isSelected: viewModel.selectedGlyph?.id == viewModel.grid[row][col].id,
                                isHinted: isHintedPosition(row: row, col: col),
                                size: cellSize
                            )
                            .onTapGesture {
                                guard !viewModel.isPaused && !viewModel.isGameOver else { return }
                                viewModel.selectGlyph(viewModel.grid[row][col])
                            }
                        }
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    // MARK: - Blessings Bar
    private var blessingsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(dragonHeartViewModel.blessings.filter { $0.count > 0 }) { blessing in
                    BlessingButton(blessing: blessing) {
                        useBlessingAction(blessing)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Game Over Overlay
    private var gameOverOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Icon
                Image(systemName: viewModel.isVictory ? "star.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(viewModel.isVictory ? Color(hex: "#FFB347") : Color(hex: "#FF4D00"))
                
                // Title
                Text(viewModel.isVictory ? "Victory!" : "Quest Failed")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                // Stats
                VStack(spacing: 12) {
                    ResultRow(title: "Score", value: "\(viewModel.score)")
                    ResultRow(title: "Energy Gained", value: "\(viewModel.energy)")
                    ResultRow(title: "Moves", value: "\(viewModel.moves)")
                }
                .padding(20)
                .background(Color(hex: "#2A2A3E"))
                .cornerRadius(15)
                
                // Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Return to Lair")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 140, height: 50)
                            .background(Color(hex: "#2A2A3E"))
                            .cornerRadius(25)
                    }
                    
                    if viewModel.isVictory {
                        Button(action: {
                            dragonHeartViewModel.completeChamber(
                                chamberNumber: viewModel.chamber.chamberNumber,
                                score: viewModel.score,
                                energy: viewModel.energy
                            )
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Continue")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 140, height: 50)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color(hex: "#FF4D00"), Color(hex: "#FFB347")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                        }
                    } else {
                        Button(action: {
                            viewModel.setupGame()
                        }) {
                            Text("Retry")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 140, height: 50)
                                .background(Color(hex: "#FF4D00"))
                                .cornerRadius(25)
                        }
                    }
                }
            }
            .padding(30)
        }
    }
    
    // MARK: - Helper Functions
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func isHintedPosition(row: Int, col: Int) -> Bool {
        guard viewModel.showHint, let hint = viewModel.hintPositions else { return false }
        return (hint.from.row == row && hint.from.column == col) ||
               (hint.to.row == row && hint.to.column == col)
    }
    
    private func useBlessingAction(_ blessing: DragonBlessing) {
        guard dragonHeartViewModel.useBlessing(blessing) else { return }
        
        switch blessing.name {
        case "Ember Sight":
            viewModel.useEmberSight()
        case "Timewyrm's Patience":
            viewModel.useTimewyrmsPatience()
        case "Dragon's Fury":
            viewModel.useDragonsFury()
        default:
            break
        }
    }
}

// MARK: - Supporting Views
struct GlyphCell: View {
    let glyph: DragonGlyph
    let isSelected: Bool
    let isHinted: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(glyph.type.color.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(
                            isSelected ? Color.white : (isHinted ? Color(hex: "#FFB347") : Color.clear),
                            lineWidth: isSelected ? 3 : (isHinted ? 2 : 0)
                        )
                )
            
            Text(glyph.type.symbol)
                .font(.system(size: size * 0.5))
        }
        .frame(width: size, height: size)
        .opacity(glyph.isMatched ? 0.3 : 1.0)
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct StatBadge: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(hex: "#2A2A3E"))
        .cornerRadius(12)
    }
}

struct BlessingButton: View {
    let blessing: DragonBlessing
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: blessing.icon)
                    .font(.system(size: 20))
                Text("x\(blessing.count)")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(Color(hex: "#FF4D00"))
            .cornerRadius(12)
        }
    }
}

struct ResultRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "#FFB347"))
        }
    }
}

