//
//  TabOnboardingView.swift
//  DarkMaze
//
//  Restores the original illustrated introduction and animated character.
//

import SwiftUI
import UIKit

struct TabOnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentTab = 0

    // The same three illustrated story beats as the original onboarding.
    private let pages: [OnboardingData] = [
        OnboardingData(
            id: 0,
            primaryText: "Welcome to Dark Maze",
            secondaryText: "An immersive game designed for blind and low-vision players."
        ),
        OnboardingData(
            id: 1,
            primaryText: "Explore complex mazes",
            secondaryText: "Engage your senses beyond vision."
        ),
        OnboardingData(
            id: 2,
            primaryText: "Listen and feel",
            secondaryText: "Use sound and haptic feedback to find your way."
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 12) {
                Spacer(minLength: 0)

                // The original hello.json Lottie character stays animated
                // across all pages instead of replacing it with text only.
                LottieView(name: "hello", loop: .loop)
                    .frame(width: min(geometry.size.width - 32, 350),
                           height: max(155, min(geometry.size.height * 0.36, 300)))
                    .accessibilityHidden(true)

                TabView(selection: $currentTab) {
                    ForEach(pages) { data in
                        VStack(spacing: 10) {
                            Text(data.primaryText)
                                .font(.system(size: 24, weight: .black, design: .monospaced))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .accessibilityAddTraits(.isHeader)
                                .accessibilityLabel(
                                    "\(data.primaryText). Page \(data.id + 1) of \(pages.count)"
                                )

                            Text(data.secondaryText)
                                .font(.system(size: 16, weight: .medium, design: .monospaced))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 12)
                        .tag(data.id)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 132)
                .onChange(of: currentTab) { page in
                    if UIAccessibility.isVoiceOverRunning {
                        UIAccessibility.post(
                            notification: .pageScrolled,
                            argument: "Page \(page + 1) of \(pages.count). \(pages[page].primaryText)"
                        )
                    }
                }

                Spacer(minLength: 0)

                // Keep actions in the same slot to prevent page layout shifts.
                // A single Next button becomes two destinations on page three.
                VStack(spacing: 12) {
                    if currentTab < pages.count - 1 {
                        squareButton("Next", primary: true) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentTab += 1
                            }
                        }
                        .accessibilityHint("Continue to the next introduction page")
                    } else {
                        squareButton("Start tutorial", primary: true) {
                            appState.startTutorial()
                        }
                        .accessibilityHint("Begin the four-stage guided tutorial")

                        squareButton("Main menu") {
                            appState.isOnboarding = false
                            appState.state = .main
                        }
                        .accessibilityHint("Skip the tutorial and open the main menu")
                    }
                }
                .frame(height: 104, alignment: .bottom)

                Spacer(minLength: 12)

                // Page dots remain anchored to the bottom, below all buttons.
                HStack(spacing: 12) {
                    ForEach(pages.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentTab ? Color.white : Color.gray)
                            .frame(width: index == currentTab ? 22 : 7, height: 7)
                    }
                }
                .accessibilityHidden(true)
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func squareButton(
        _ title: String,
        primary: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(primary ? .black : .white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 46)
                .background(primary ? Color.white : Color.black)
                .overlay(Rectangle().stroke(.white, lineWidth: primary ? 0 : 2))
        }
        .buttonStyle(.plain)

    }
}
