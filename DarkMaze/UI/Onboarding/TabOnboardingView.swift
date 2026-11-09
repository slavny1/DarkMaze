//
//  TabOnboardingView.swift
//  DarkMaze
//

import SwiftUI

// A single VoiceOver-first entry screen replaces the swipe-only onboarding.
// No gesture or visual animation is required to begin playing.
struct TabOnboardingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 24) {
            Text("Welcome to DarkMaze")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Text(
                "Find your way through a maze using sound and vibration. " +
                "Drag the ball directly, or tilt the on-screen joystick for slow movement. " +
                "With VoiceOver, focus the ball and use its directional actions. " +
                "Walls make sound before you touch them; a collision sends the ball back to the start."
            )
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("We recommend starting with the sound signals, then trying three short practice mazes.")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Button("Explore sounds and vibrations") {
                appState.isOnboarding = false
                appState.state = .signals
            }
            .accessibilityHint("Practice the sounds and vibrations used during play")

            Button("Start guided tutorial") {
                appState.startTutorial()
            }
            .accessibilityHint("Start with a simple straight corridor")

            Button("Go to main menu") {
                appState.isOnboarding = false
                appState.state = .main
            }
            .accessibilityHint("Skip introduction. You can return to the tutorial later.")
        }
        .padding(28)
        .foregroundColor(.white)
        .buttonStyle(.bordered)
    }
}
