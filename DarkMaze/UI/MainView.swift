//
//  MainView.swift
//  DarkMaze
//

import SwiftUI
import AVFoundation

struct MainView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: -32) {
                Text("DARK")
                Text("MAZE")
            }
            .font(.system(size: 104, weight: .black, design: .monospaced))
            .foregroundColor(.white)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Dark Maze")
            .accessibilityAddTraits(.isHeader)

            Text("Top level: \(appState.topLevel.rawValue)")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .accessibilityLabel("Top level \(appState.topLevel.rawValue)")

            menuButton("Start game", primary: true) {
                appState.startRegularGame(level: appState.topLevel)
            }
            .accessibilityHint("Continue your unlocked game levels")

            menuButton("Levels") {
                appState.state = .level
            }

            menuButton("Tutorial") {
                appState.startTutorial()
            }
            .accessibilityHint("Play three short beginner mazes")

            menuButton("Sounds and haptics") {
                appState.state = .signals
            }
            .accessibilityHint("Practice game sounds and vibrations before playing")

            Toggle(isOn: $appState.blindMode) {
                Text(appState.blindMode ? "Blind mode on" : "Blind mode off")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
            }
            .toggleStyle(BlindModeToggleStyle())
            .frame(width: 250, height: 48)
            .accessibilityLabel("Blind mode")
            .accessibilityHint("Hides visible maze corridors but keeps audio and vibration")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }

    private func menuButton(
        _ title: String,
        primary: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            HapticManager.buttonTapped()
            action()
        } label: {
            Text(title)
                .font(.system(size: 21, weight: .black, design: .monospaced))
                .foregroundColor(primary ? .black : .white)
                .frame(width: 250, height: 50)
                .background(primary ? Color.white : Color.black)
                .overlay(Rectangle().stroke(.white, lineWidth: primary ? 0 : 3))
        }
        .buttonStyle(.plain)
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
