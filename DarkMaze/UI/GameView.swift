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
    @State private var joystickTouched = false
    @AccessibilityFocusState private var isJoystickFocused: Bool

    private let joystickRadius: CGFloat = 50
    private let frameDuration: CGFloat = 1.0 / 60.0
    private let movementTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    private var heading: String {
        if let stage = appState.tutorialStage {
            return "Tutorial \(stage + 1) of 4"
        }
        return "Level \(appState.gameLevel.rawValue + 1)"
    }

    private var instructions: String {
        switch appState.tutorialStage {
        case 0:
            return "Move the ball slowly and listen as it approaches a wall. Find the end of the corridor without touching walls."
        case 1:
            return "Explore a corridor with a turn. Changes in the sound help you sense nearby walls."
        case 2:
            return "The ball is hidden. Navigate using the joystick and wall signals."
        case 3:
            return "The finish is hidden too. Find it by sound and touch."
        default:
            return "Drag the ball directly or hold the joystick gently. " +
                "Wall sounds grow louder as you approach. " +
                "Touching a wall returns the ball to the start."
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


                HStack(spacing: 8) {
                    visibilityButton("Maze", hidden: appState.blindMode) {
                        appState.blindMode.toggle()
                        gameScene?.updateVisibility()
                    }
                    visibilityButton("Ball", hidden: appState.hideBall) {
                        appState.hideBall.toggle()
                        gameScene?.updateVisibility()
                    }
                    visibilityButton("Finish", hidden: appState.hideFinish) {
                        appState.hideFinish.toggle()
                        gameScene?.updateVisibility()
                    }
                }
                .padding(.top, 2)

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
                    DispatchQueue.main.async { isJoystickFocused = true }
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
                    if !joystickTouched {
                        joystickTouched = true
                        HapticManager.joystickLocated()
                    }
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    let distance = hypot(horizontal, vertical)
                    let scale = distance > joystickRadius ? joystickRadius / distance : 1
                    joystickOffset = CGSize(width: horizontal * scale, height: vertical * scale)
                }
                .onEnded { _ in
                    joystickTouched = false
                    joystickOffset = .zero
                    joystickRequiresRelease = false
                    gameScene?.releaseJoystick()
                }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Joystick, bottom centre")
        .accessibilityHint("Touch and hold, then drag gently to steer the ball")
        .accessibilityAddTraits(.allowsDirectInteraction)
        .accessibilityFocused($isJoystickFocused)
    }

    private func visibilityButton(
        _ label: String,
        hidden: Bool,
        onTap: @escaping () -> Void
    ) -> some View {
        Button {
            onTap()
            HapticManager.buttonTapped()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: hidden ? "eye.slash" : "eye")
                Text(label)
            }
            .font(.system(size: 11, weight: .bold, design: .monospaced))
            .foregroundColor(hidden ? .gray : .white)
            .frame(minWidth: 70, minHeight: 34)
            .overlay(Rectangle().stroke(.white.opacity(0.6), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label), \(hidden ? "hidden" : "visible")")
        .accessibilityHint("Double tap to toggle visibility")
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
