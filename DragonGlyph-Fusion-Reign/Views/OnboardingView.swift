//
//  OnboardingView.swift
//  DragonGlyph: Fusion Reign
//
//  Session ID: 7582-DR
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#0A0A12")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == viewModel.currentPage ? Color(hex: "#FF4D00") : Color(hex: "#2A2A3E"))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.pages.count, id: \.self) { index in
                        OnboardingPageView(page: viewModel.pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    if viewModel.currentPage > 0 {
                        Button(action: {
                            viewModel.previousPage()
                        }) {
                            Text("Previous")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(hex: "#00E0FF"))
                                .frame(width: 120, height: 50)
                                .background(Color(hex: "#2A2A3E"))
                                .cornerRadius(25)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if viewModel.currentPage == viewModel.pages.count - 1 {
                            hasCompletedOnboarding = true
                        } else {
                            viewModel.nextPage()
                        }
                    }) {
                        Text(viewModel.currentPage == viewModel.pages.count - 1 ? "Begin Journey" : "Next")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 160, height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(hex: "#FF4D00"), Color(hex: "#FFB347")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color(hex: "#FF4D00").opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [page.color.opacity(0.3), page.color.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 50))
                    .foregroundColor(page.color)
            }
            .padding(.top, 40)
            
            // Title
            Text(page.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // Description
            Text(page.description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(Color.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 40)
        }
    }
}

