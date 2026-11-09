//
//  GameView.swift
//  DarkMaze
//

import SwiftUI
import SpriteKit
import UIKit
import Combine

struct GameView: View {
    @EnvironmentObject private var appState: AppState
    @State private var gameScene: GameScene?
    @State private var joystickOffset: CGSize = .zero
    @State private var joystickRequiresRelease = false
    @AccessibilityFocusState private var isBallFocused: Bool

    private let joystickRadius: CGFloat = 50
    private let frameDuration: CGFloat = 1.0 / 60.0
    private let movementTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    private var heading: String {
        if let stage = appState.tutorialStage {
            return "Tutorial \(stage + 1) of 3"
        }
        return "Level \(appState.gameLevel.rawValue)"
    }

    private var instructions: String {
        switch appState.tutorialStage {
        case 0:
            return "Move the ball slowly and listen as it approaches a wall. Find the end of the corridor without touching walls."
        case 1:
            return "Explore a corridor with a turn. Changes in the sound help you sense nearby walls."
        case 2:
            return "Find your way through the winding maze using only sound and touch."
        default:
            return "Drag the ball directly or hold the joystick gently. Wall sounds grow louder as you approach. Touching a wall sends the ball back to the start."
        }
    }

    var body: some View {
        // The playfield must not scroll when the joystick is dragged.
        GeometryReader { geometry in
            let mazeSide = max(
                180,
                min(geometry.size.width - 32, geometry.size.height - 310, 390)
            )

            VStack(spacing: 12) {
                Text(heading)
                    .font(.headline)
                    .foregroundColor(.white)
                    .accessibilityAddTraits(.isHeader)

                if let gameScene {
                    SpriteView(scene: gameScene, transition: nil)
                        .frame(width: mazeSide, height: mazeSide)
                        .clipped()
                        .accessibilityHidden(true)
                }

                // A navigable VoiceOver representation of the real SpriteKit ball.
                // Each custom action nudges it a small fraction of a tile.
                Button {
                    HapticManager.ballTouched()
                    UIAccessibility.post(
                        notification: .announcement,
                        argument: "Ball selected. Choose a direction with VoiceOver actions."
                    )
                } label: {
                    Label("Ball", systemImage: "circle.fill")
                        .foregroundColor(.white)
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 5)
                }
                .accessibilityLabel("Player ball")
                .accessibilityHint("Use the VoiceOver actions to nudge the ball gently.")
                .accessibilityFocused($isBallFocused)
                .accessibilityAction(named: Text("Nudge up")) {
                    gameScene?.nudgeBall(dx: 0, dy: 1)
                }
                .accessibilityAction(named: Text("Nudge down")) {
                    gameScene?.nudgeBall(dx: 0, dy: -1)
                }
                .accessibilityAction(named: Text("Nudge left")) {
                    gameScene?.nudgeBall(dx: -1, dy: 0)
                }
                .accessibilityAction(named: Text("Nudge right")) {
                    gameScene?.nudgeBall(dx: 1, dy: 0)
                }

                joystick
                    .padding(.vertical, 4)

                Button("Repeat instructions") {
                    UIAccessibility.post(notification: .announcement, argument: instructions)
                }
                .foregroundColor(.white)
                .accessibilityHint("Explains the controls without revealing a route")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.bottom, 12)
            .onAppear {
                setupScene(side: mazeSide)
                if UIAccessibility.isVoiceOverRunning {
                    DispatchQueue.main.async { isBallFocused = true }
                }
            }
        }
        .onReceive(movementTimer) { _ in
            guard !joystickRequiresRelease else { return }
            let horizontal = joystickOffset.width / joystickRadius
            let vertical = -joystickOffset.height / joystickRadius
            gameScene?.steer(horizontal: horizontal,
                             vertical: vertical,
                             deltaTime: frameDuration)
        }
        .onDisappear {
            gameScene?.onCollision = nil
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
                Button("Reset") { appState.gameID = UUID() }
                    .accessibilityHint("Restart this maze from the beginning")
            }
        }
    }

    private var joystick: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white.opacity(0.75), lineWidth: 2)
                .background(Circle().fill(Color.white.opacity(0.09)))
                .frame(width: 146, height: 146)

            Circle()
                .fill(.white)
                .frame(width: 55, height: 55)
                .offset(joystickOffset)
        }
        .frame(width: 160, height: 160)
        .contentShape(Circle())
        .highPriorityGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    guard !joystickRequiresRelease else { return }
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    let distance = hypot(horizontal, vertical)
                    let scale = distance > joystickRadius ? joystickRadius / distance : 1
                    joystickOffset = CGSize(width: horizontal * scale, height: vertical * scale)
                }
                .onEnded { _ in
                    joystickOffset = .zero
                    joystickRequiresRelease = false
                    gameScene?.releaseJoystick()
                }
        )
        .accessibilityHidden(true)
    }

    private func setupScene(side: CGFloat) {
        guard gameScene == nil else { return }
        let scene = GameScene(appState: appState, size: CGSize(width: side, height: side))
        scene.scaleMode = .aspectFit
        scene.onCollision = {
            joystickOffset = .zero
            joystickRequiresRelease = true
        }
        gameScene = scene
    }
}
