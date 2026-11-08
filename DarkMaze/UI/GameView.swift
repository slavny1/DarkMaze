//
//  GameView.swift
//  DarkMaze
//

import SwiftUI
import SpriteKit
import UIKit

struct GameView: View {
    @EnvironmentObject private var appState: AppState
    @State private var gameScene: GameScene?
    @State private var status = "Find the ball, then choose a direction."

    private var heading: String {
        if let stage = appState.tutorialStage {
            return "Tutorial \(stage + 1) of 3"
        }
        return "Level \(appState.gameLevel.rawValue)"
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(heading)
                .font(.headline)
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            if let gameScene {
                SpriteView(scene: gameScene, transition: nil)
                    .frame(width: UIScreen.main.bounds.width,
                           height: UIScreen.main.bounds.width)
                    .accessibilityHidden(true)
            }

            // This is the ball's accessible representation. The actual
            // SpriteKit ball remains available for direct touch dragging.
            Button {
                HapticManager.ballTouched()
                status = "Ball selected. Use the direction buttons."
            } label: {
                Label("Ball", systemImage: "circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 9)
                    .background(Color.gray.opacity(0.3), in: Capsule())
            }
            .accessibilityLabel("Player ball")
            .accessibilityValue(status)
            .accessibilityHint("Double tap to select. Use the movement buttons, or VoiceOver actions.")
            .accessibilityAction(named: Text("Move up")) { move(0, 1) }
            .accessibilityAction(named: Text("Move down")) { move(0, -1) }
            .accessibilityAction(named: Text("Move left")) { move(-1, 0) }
            .accessibilityAction(named: Text("Move right")) { move(1, 0) }

            // A touch-friendly directional pad. Each direction is also a
            // separately focusable, named VoiceOver button.
            VStack(spacing: 5) {
                directionButton("Up", symbol: "arrow.up", dx: 0, dy: 1)
                HStack(spacing: 16) {
                    directionButton("Left", symbol: "arrow.left", dx: -1, dy: 0)
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 32, height: 32)
                        .accessibilityHidden(true)
                    directionButton("Right", symbol: "arrow.right", dx: 1, dy: 0)
                }
                directionButton("Down", symbol: "arrow.down", dx: 0, dy: -1)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Movement joystick")

            Text(status)
                .font(.footnote)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Game status")
                .accessibilityValue(status)
        }
        .padding(.bottom, 12)
        .onAppear(perform: setupScene)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Main") {
                    appState.tutorialStage = nil
                    appState.state = .main
                }
                .accessibilityHint("Exit the current maze")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                    appState.gameID = UUID()
                }
                .accessibilityHint("Restart this maze from the beginning")
            }
        }
    }

    private func directionButton(_ name: String, symbol: String, dx: Int, dy: Int) -> some View {
        Button {
            move(dx, dy)
        } label: {
            Image(systemName: symbol)
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
                .frame(width: 68, height: 46)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 10))
        }
        .accessibilityLabel("Move \(name.lowercased())")
        .accessibilityHint("Move the ball one tile \(name.lowercased())")
    }

    private func move(_ dx: Int, _ dy: Int) {
        gameScene?.moveBall(dx: dx, dy: dy)
    }

    private func setupScene() {
        guard gameScene == nil else { return }
        let side = UIScreen.main.bounds.width
        let scene = GameScene(appState: appState, size: CGSize(width: side, height: side))
        scene.scaleMode = .aspectFit
        scene.onStatusChange = { message in
            status = message
            if message.hasPrefix("Wall") || message == "Goal reached!" {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
        gameScene = scene
    }
}
