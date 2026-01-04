//
//  DragonCodexView.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import SwiftUI

struct DragonCodexView: View {
    @EnvironmentObject var viewModel: DragonHeartViewModel
    @Environment(\.presentationMode) var presentationMode
    
    private let allGlyphTypes = GlyphType.allCases
    
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
                    
                    Text("Dragon Codex")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for symmetry
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                
                // Discovery Stats
                VStack(spacing: 8) {
                    Text("Glyphs Discovered")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.6))
                    Text("\(viewModel.playerProgress.glyphsDiscovered.count) / \(allGlyphTypes.count)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#FFB347"))
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color(hex: "#2A2A3E"))
                .cornerRadius(15)
                .padding(.horizontal, 20)
                
                // Glyph Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(allGlyphTypes, id: \.self) { glyphType in
                            GlyphCodexCard(
                                glyphType: glyphType,
                                isDiscovered: viewModel.playerProgress.glyphsDiscovered.contains(glyphType.rawValue)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

struct GlyphCodexCard: View {
    let glyphType: GlyphType
    let isDiscovered: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Glyph Symbol
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                glyphType.color.opacity(isDiscovered ? 0.3 : 0.1),
                                glyphType.color.opacity(isDiscovered ? 0.1 : 0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                if isDiscovered {
                    Text(glyphType.symbol)
                        .font(.system(size: 40))
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color.white.opacity(0.3))
                }
            }
            
            // Name
            Text(isDiscovered ? glyphType.rawValue : "???")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isDiscovered ? .white : Color.white.opacity(0.4))
            
            // Power Level
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index < glyphType.powerLevel && isDiscovered ? Color(hex: "#FFB347") : Color(hex: "#2A2A3E"))
                        .frame(width: 8, height: 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(hex: "#2A2A3E"))
        .cornerRadius(15)
    }
}

