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
    @State private var lastJoystickMove = Date.distantPast
    @AccessibilityFocusState private var isBallFocused: Bool

    private var instructions: String {
        switch appState.tutorialStage {
        case 0:
            return "Practice moving the ball with the joystick or direction buttons. Listen to sounds and feel vibrations as you explore the corridor."
        case 1:
            return "Explore a corridor with a turn. Use sounds and vibrations to discover the route yourself."
        case 2:
            return "Explore a winding maze. Listen and feel for obstacles while finding the goal."
        default:
            return "Move the ball through the maze using the joystick, direction buttons, or direct dragging. Let sounds and vibrations guide you."
        }
    }

    private var heading: String {
        if let stage = appState.tutorialStage {
            return "Tutorial \(stage + 1) of 3"
        }
        return "Level \(appState.gameLevel.rawValue)"
    }

    var body: some View {
        ScrollView {
          VStack(spacing: 12) {
            Text(heading)
                .font(.headline)
                .foregroundColor(.white)
                .accessibilityAddTraits(.isHeader)

            if let gameScene {
                SpriteView(scene: gameScene, transition: nil)
                    .frame(
                        width: min(UIScreen.main.bounds.width - 32, 390),
                        height: min(UIScreen.main.bounds.width - 32, 390)
                    )
                    .accessibilityHidden(true)
            }

            // This is the ball's accessible representation. The actual
            // SpriteKit ball remains available for direct touch dragging.
            Button {
                HapticManager.ballTouched()
                UIAccessibility.post(notification: .announcement, argument: "Ball selected. Use the movement buttons or custom VoiceOver actions.")
            } label: {
                Label("Ball", systemImage: "circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 9)
                    .background(Color.gray.opacity(0.3), in: Capsule())
            }
            .accessibilityLabel("Player ball")
            .accessibilityFocused($isBallFocused)
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
                    // Touch joystick; VoiceOver uses the surrounding buttons.
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .overlay {
                            Circle().strokeBorder(.white.opacity(0.8), lineWidth: 2)
                        }
                        .frame(width: 58, height: 58)
                        .contentShape(Circle())
                        .gesture(
                            DragGesture(minimumDistance: 12)
                                .onChanged { value in
                                    let now = Date()
                                    guard now.timeIntervalSince(lastJoystickMove) >= 0.2 else { return }
                                    let x = value.translation.width
                                    let y = value.translation.height
                                    guard max(abs(x), abs(y)) >= 15 else { return }
                                    lastJoystickMove = now
                                    if abs(x) > abs(y) {
                                        move(x > 0 ? 1 : -1, 0)
                                    } else {
                                        move(0, y < 0 ? 1 : -1)
                                    }
                                }
                        )
                        .accessibilityHidden(true)
                    directionButton("Right", symbol: "arrow.right", dx: 1, dy: 0)
                }
                directionButton("Down", symbol: "arrow.down", dx: 0, dy: -1)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Movement joystick")

            Button("Repeat instructions") {
                UIAccessibility.post(notification: .announcement, argument: instructions)
            }
            .accessibilityHint("Hear the objective for this maze again")

            Text("Drag the joystick, move the ball directly, or use the direction buttons.")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

        }
          .frame(maxWidth: .infinity)
          .padding(.bottom, 12)
        }
        .onAppear {
            setupScene()
            // VoiceOver starts on the ball rather than on an inaccessible
            // SpriteKit canvas. Four named movement actions are available.
            if UIAccessibility.isVoiceOverRunning {
                DispatchQueue.main.async {
                    isBallFocused = true
                }
            }
        }
        .onDisappear {
            gameScene = nil
        }
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
        let side = min(UIScreen.main.bounds.width - 32, 390)
        let scene = GameScene(appState: appState, size: CGSize(width: side, height: side))
        scene.scaleMode = .aspectFit
        gameScene = scene
    }
}
