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
    @State private var isJoystickCentered = true
    @State private var mazeFrame: CGRect = .zero
    @State private var joystickFrame: CGRect = .zero
    @State private var discoveredTarget: DiscoveryTarget?
    @State private var discoveryAudio = DiscoveryAudioManager()
    @AccessibilityFocusState private var isBallFocused: Bool

    private let joystickRadius: CGFloat = 50
    private let neutralRadius: CGFloat = 11
    private let frameDuration: CGFloat = 1.0 / 60.0
    private let movementTimer = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common).autoconnect()

    private var heading: String {
        if let stage = appState.tutorialStage {
            return "Tutorial \(stage + 1) of 3"
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
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: MazeDiscoveryFrameKey.self,
                                    value: proxy.frame(in: .named("discoverySpace"))
                                )
                            }
                        )
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Maze, touch to find the ball")
                        .accessibilityHint(
                            "Explore by touch. Select the ball to drag it. " +
                            "VoiceOver actions allow small nudges."
                        )
                        .accessibilityAddTraits(.allowsDirectInteraction)
                        .accessibilityFocused($isBallFocused)
                        .accessibilityAction(named: Text("Nudge up")) {
                            gameScene.nudgeBall(horizontal: 0, vertical: 1)
                        }
                        .accessibilityAction(named: Text("Nudge down")) {
                            gameScene.nudgeBall(horizontal: 0, vertical: -1)
                        }
                        .accessibilityAction(named: Text("Nudge left")) {
                            gameScene.nudgeBall(horizontal: -1, vertical: 0)
                        }
                        .accessibilityAction(named: Text("Nudge right")) {
                            gameScene.nudgeBall(horizontal: 1, vertical: 0)
                        }
                }


                joystick
                    .padding(.vertical, 4)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: JoystickDiscoveryFrameKey.self,
                                value: proxy.frame(in: .named("discoverySpace"))
                            )
                        )

                Button("Repeat instructions") {
                    UIAccessibility.post(notification: .announcement, argument: instructions)
                }
                .foregroundColor(.white)
                .accessibilityHint("Explains the controls without revealing a route")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.bottom, 12)
            .coordinateSpace(name: "discoverySpace")
            .simultaneousGesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .named("discoverySpace"))
                    .onChanged { scanFinger(at: $0.location) }
                    .onEnded { _ in stopDiscovery() }
            )
            .onPreferenceChange(MazeDiscoveryFrameKey.self) { mazeFrame = $0 }
            .onPreferenceChange(JoystickDiscoveryFrameKey.self) { joystickFrame = $0 }
            .onAppear {
                setupScene(side: mazeSide)
                if UIAccessibility.isVoiceOverRunning {
                    DispatchQueue.main.async { isBallFocused = true }
                }
            }
        }
        .onReceive(movementTimer) { _ in
            guard !joystickRequiresRelease else { return }
            let displacement = hypot(joystickOffset.width, joystickOffset.height)
            let activeRange = joystickRadius - neutralRadius
            let normalized = max(0, (displacement - neutralRadius) / activeRange)
            // Fine control close to centre; full speed only at the rim.
            let speedFactor = pow(normalized, 1.5)
            let horizontal = displacement > 0 ?
                joystickOffset.width / displacement * speedFactor : 0
            let vertical = displacement > 0 ?
                -joystickOffset.height / displacement * speedFactor : 0
            gameScene?.steer(horizontal: horizontal,
                             vertical: vertical,
                             deltaTime: frameDuration)
        }
        .onDisappear {
            stopDiscovery()
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
                    }
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    let distance = hypot(horizontal, vertical)
                    // The neutral zone is a physical-feeling detent.
                    // Snap the knob precisely to the centre and pulse only
                    // once when returning there from active movement.
                    if distance <= neutralRadius {
                        joystickOffset = .zero
                        if !isJoystickCentered {
                            isJoystickCentered = true
                            HapticManager.joystickCentered()
                        }
                    } else {
                        isJoystickCentered = false
                        let scale = distance > joystickRadius ? joystickRadius / distance : 1
                        joystickOffset = CGSize(width: horizontal * scale, height: vertical * scale)
                    }
                }
                .onEnded { _ in
                    joystickTouched = false
                    if !isJoystickCentered {
                        HapticManager.joystickCentered()
                    }
                    isJoystickCentered = true
                    joystickOffset = .zero
                    joystickRequiresRelease = false
                    gameScene?.releaseJoystick()
                }
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Joystick, bottom centre")
        .accessibilityHint("Touch and hold, then drag gently to steer the ball")
        .accessibilityAddTraits(.allowsDirectInteraction)
    }

    private func scanFinger(at location: CGPoint) {
        guard let gameScene, let ballPoint = gameScene.ballPositionInView,
              mazeFrame.width > 0, joystickFrame.width > 0 else { return }

        // Translate the moving SpriteKit ball into the fixed screen layout.
        let ballCentre = CGPoint(
            x: mazeFrame.minX + ballPoint.x * mazeFrame.width / gameScene.size.width,
            y: mazeFrame.minY + ballPoint.y * mazeFrame.height / gameScene.size.height
        )
        let ballDistance = hypot(location.x - ballCentre.x, location.y - ballCentre.y)
        let joystickDistance = hypot(
            location.x - joystickFrame.midX,
            location.y - joystickFrame.midY
        )

        // The ball remains discoverable even if its visual alpha is zero.
        // The joystick has a larger touch target for blind exploration.
        let insideBall = ballDistance < 30 && mazeFrame.contains(location)
        let insideJoystick = joystickDistance < 76 && joystickFrame.contains(location)
        let enteredTarget: DiscoveryTarget? =
            insideJoystick ? .joystick : (insideBall ? .ball : nil)

        if let enteredTarget {
            discoveryAudio.stopScanning()
            if discoveredTarget != enteredTarget {
                discoveredTarget = enteredTarget
                discoveryAudio.confirm(enteredTarget)
                if enteredTarget == .ball {
                    HapticManager.ballTouched()
                } else {
                    HapticManager.joystickLocated()
                }
            }
            return
        }

        discoveredTarget = nil
        let ballProximity = max(0, 1 - ballDistance / 125)
        let joystickProximity = max(0, 1 - joystickDistance / 140)
        if joystickProximity > ballProximity {
            discoveryAudio.update(target: .joystick, proximity: joystickProximity)
        } else {
            discoveryAudio.update(target: .ball, proximity: ballProximity)
        }
    }

    private func stopDiscovery() {
        discoveredTarget = nil
        discoveryAudio.stopScanning()
    }

    private func setupScene(side: CGFloat) {
        guard gameScene == nil else { return }
        let scene = GameScene(appState: appState, size: CGSize(width: side, height: side))
        scene.scaleMode = .aspectFit
        scene.onCollision = {
            joystickOffset = .zero
            isJoystickCentered = true
            joystickRequiresRelease = true
        }
        gameScene = scene
    }
}

private struct MazeDiscoveryFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

private struct JoystickDiscoveryFrameKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
