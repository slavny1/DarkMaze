//
//  MainView.swift
//  DarkMaze
//

import SwiftUI
import AVFoundation

struct MainView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 18) {
            Text("DARK MAZE")
                .font(.system(size: 42, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Text("Explore a maze with sound and touch.")
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Button("Start tutorial") {
                HapticManager.buttonTapped()
                appState.startTutorial()
            }
            .accessibilityHint("Begin with a straight corridor and learn to move the ball")

            Button("Learn sounds and vibrations") {
                HapticManager.buttonTapped()
                appState.state = .signals
            }
            .accessibilityHint("Listen to and feel the game's signals")

            Button("Continue game") {
                HapticManager.buttonTapped()
                appState.startRegularGame(level: appState.topLevel)
            }

            Button("Levels") {
                HapticManager.buttonTapped()
                appState.state = .level
            }

            Toggle("Hide the maze visually", isOn: $appState.blindMode)
                .accessibilityHint("Visual appearance only. Sounds and accessible controls work in either mode.")
        }
        .buttonStyle(AccessibleMenuButtonStyle())
        .padding(25)
    }
}

private struct AccessibleMenuButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding(13)
            .background(Color.white.opacity(configuration.isPressed ? 0.7 : 1),
                        in: RoundedRectangle(cornerRadius: 12))
    }
}

// The same sounds and haptics used during play can be rehearsed here.
struct SignalTrainingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var player: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 18) {
            Text("Learn the signals")
                .font(.title.bold())
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Text("Activate each signal to hear and feel it. Use headphones for the clearest sound.")
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            signalButton("Find the ball", file: "bonus", hint: "Ball selected") {
                HapticManager.ballTouched()
            }
            signalButton("Near a wall", file: "ufo", hint: "Movement sound; louder near walls") {
                HapticManager.ballMoving()
            }
            signalButton("Hit a wall", file: "wall", hint: "Collision, choose another direction") {
                HapticManager.collisionOccurred()
            }
            signalButton("Outside the maze", file: "edge", hint: "Boundary signal") {
                HapticManager.collisionOccurred()
            }
            signalButton("Reach the goal", file: "win", hint: "Success!") {
                HapticManager.ballWin()
            }

            Button("Start first tutorial level") {
                stopSound()
                appState.startTutorial()
            }
            .padding(12)

            Button("Back to main") {
                stopSound()
                appState.state = .main
            }
        }
        .foregroundColor(.white)
        .padding(24)
        .onDisappear(perform: stopSound)
    }

    private func signalButton(_ label: String, file: String,
                              hint: String, haptic: @escaping () -> Void) -> some View {
        Button {
            playSound(named: file)
            haptic()
        } label: {
            Label(label, systemImage: "speaker.wave.2")
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(Color.gray.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
        }
        .accessibilityHint(hint)
    }

    private func playSound(named name: String) {
        stopSound()
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 0.7
            player?.play()
        } catch {
            print("Signal playback failed: \(error.localizedDescription)")
        }
    }

    private func stopSound() {
        player?.stop()
        player = nil
    }
}
