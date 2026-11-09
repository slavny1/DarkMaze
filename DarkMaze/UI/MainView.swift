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

            Text("Top level: \(appState.topLevel.rawValue + 1)")
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .accessibilityLabel("Top level \(appState.topLevel.rawValue + 1)")

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

// Sound rehearsal with the same square and monochrome visual language.
struct SignalTrainingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var player: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 14) {
            Text("SOUNDS")
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            Text("Play each signal to learn its meaning.")
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            signalButton("Find ball", file: "bonus",
                         hint: "The ball was found by touch") {
                HapticManager.ballTouched()
            }
            signalButton("Near wall", file: "ufo",
                         hint: "This sound grows louder as a wall gets closer") {
                HapticManager.ballMoving()
            }
            signalButton("Collision", file: "wall",
                         hint: "Hitting a wall returns the ball to the start") {
                HapticManager.collisionOccurred()
            }
            signalButton("Boundary", file: "edge",
                         hint: "The edge of the maze") {
                HapticManager.collisionOccurred()
            }
            signalButton("Goal", file: "win",
                         hint: "Successfully reaching the end of a maze") {
                HapticManager.ballWin()
            }

            squareButton("Start tutorial", filled: true) {
                stopSound()
                appState.startTutorial()
            }
            squareButton("Main menu") {
                stopSound()
                appState.state = .main
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .onDisappear(perform: stopSound)
    }

    private func squareButton(
        _ title: String,
        filled: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .black, design: .monospaced))
                .foregroundColor(filled ? .black : .white)
                .frame(width: 250, height: 48)
                .background(filled ? Color.white : Color.black)
                .overlay(Rectangle().stroke(.white, lineWidth: filled ? 0 : 3))
        }
        .buttonStyle(.plain)
    }

    private func signalButton(
        _ title: String,
        file: String,
        hint: String,
        haptic: @escaping () -> Void
    ) -> some View {
        squareButton(title) {
            playSound(named: file)
            haptic()
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
