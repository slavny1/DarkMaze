//
//  GameScene.swift
//  DarkMaze
//
//  Created by Viacheslav on 08/04/23.
//

import Foundation
import SpriteKit
import UIKit

final class GameScene: SKScene {
    private enum Constants {
        static let borderLineWidth: CGFloat = 1
    }

    private var appState: AppState

    private var lastTouchLocation: CGPoint?
    private var initialPosition: CGPoint? // position for ball
    private var mazeTiles: [[UInt8]] = []
    private var tileWidth: CGFloat = 0
    private var mazeOffset: CGFloat = 0
    private var goal: (row: Int, column: Int) = (0, 0)
    private var gameFinished = false

    private var sizeConst: CGFloat {
        min(size.width, size.height) - 2 * Constants.borderLineWidth
    }

    private var ball: SKShapeNode!
    var fatherTile: SKShapeNode!

    private var audioPlayer: AudioManager?
    private var volume: Float = 0

    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let all: UInt32 = UInt32.max
        static let ball: UInt32 = 0b1
        static let block: UInt32 = 0b10
        static let win: UInt32 = 0b100
    }

    init(appState: AppState, size: CGSize) {
        self.appState = appState
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        guard fatherTile == nil else { return }
        createFather()
        createMaze()
        createBall()
        updateVisibility()
        audioPlayer = AudioManager()

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    private func createFather() {
        fatherTile = SKShapeNode(rectOf: .init(width: sizeConst, height: sizeConst))
        // if it's blind mode all canvas will be black otherwise path will be gray
        fatherTile.fillColor = .black
        fatherTile.strokeColor = .black
        fatherTile.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(fatherTile)
    }

    // MARK: Maze creation

    private func createMaze() {
        if let stage = appState.tutorialStage {
            let tutorial = MazeLibrary.tutorialMaze(stage: stage)
            mazeTiles = tutorial.tiles
            goal = tutorial.goal
        } else {
            mazeTiles = MazeLibrary.randomMaze(level: appState.gameLevel)
            goal = (mazeTiles.count - 1, mazeTiles.count - 1)
        }

        // Square cells and deterministic start/goal for the tutorial.
        tileWidth = sizeConst / CGFloat(mazeTiles.count)
        mazeOffset = tileWidth / 2 - sizeConst / 2 + Constants.borderLineWidth
        let mazeLevelOne = mazeTiles

        // Set a position for the ball
        initialPosition = CGPoint(x: mazeOffset, y: mazeOffset)

        for row in 0..<mazeLevelOne.count {
            for column in 0..<mazeLevelOne[row].count {
                let tile = TileNode(rectOf: .init(width: tileWidth, height: tileWidth))
                tile.type = .gray

                // define position of a tile
                tile.position = CGPoint(x: mazeOffset + CGFloat(column) * tileWidth,
                                        y: mazeOffset + CGFloat(row) * tileWidth)

                // If matrix number is == 0 then its BLOCK
                if mazeLevelOne[row][column] == 0 {
                    tile.type = .wall
                    tile.physicsBody = SKPhysicsBody(rectangleOf: tile.frame.size)
                    tile.physicsBody?.isDynamic = true
                    tile.physicsBody?.categoryBitMask = PhysicsCategory.block
                    tile.physicsBody?.contactTestBitMask = PhysicsCategory.ball
                    tile.physicsBody?.collisionBitMask = PhysicsCategory.none
                }

                // For the last tile -- WIN
                if row == goal.row && column == goal.column {
                    tile.type = .win
                    tile.physicsBody = SKPhysicsBody(rectangleOf: tile.frame.size)
                    tile.physicsBody?.isDynamic = true
                    tile.physicsBody?.categoryBitMask = PhysicsCategory.win
                    tile.physicsBody?.contactTestBitMask = PhysicsCategory.ball
                    tile.physicsBody?.collisionBitMask = PhysicsCategory.none
                }
                fatherTile.addChild(tile)
            }
        }
    }

    private func createBall() {
        // Keep the ball smaller than a corridor for precise wall exploration.
        let radius = tileWidth * 0.12
        ball = SKShapeNode(circleOfRadius: radius)
        ball.fillColor = .white
        ball.strokeColor = .white
        ball.alpha = appState.hideBall ? 0 : 1
        ball.position = initialPosition ?? .zero
        fatherTile.addChild(ball)
        updateWallSound()
    }

    /// Visibility never affects wall detection, sound, or win logic.
    func updateVisibility() {
        guard fatherTile != nil, ball != nil else { return }
        for case let tile as TileNode in fatherTile.children {
            switch tile.type {
            case .wall:
                tile.fillColor = .black
                tile.strokeColor = appState.blindMode ? .black : .white
            case .win:
                tile.fillColor = appState.hideFinish ?
                    (appState.blindMode ? .black : .gray) : .white
                tile.strokeColor = appState.blindMode ? .black : .white
            default:
                tile.fillColor = appState.blindMode ? .black : .gray
                tile.strokeColor = appState.blindMode ? .black : .white
            }
        }
        ball.alpha = appState.hideBall ? 0 : 1
    }

    private var ballRadius: CGFloat { tileWidth * 0.12 }
    private var touchIsDragging = false
    private var joystickNeedsRelease = false
    private var ballFoundDuringTouch = false

    /// Informs the SwiftUI joystick to return to neutral after a collision.
    var onCollision: (() -> Void)?

    /// Apply a small displacement in scene points rather than whole tiles.
    /// Both the touch gesture and the joystick share this collision logic.
    func moveBall(by displacement: CGVector) {
        guard !gameFinished, !joystickNeedsRelease, ball != nil else { return }
        let distance = hypot(displacement.dx, displacement.dy)
        guard distance > 0 else { return }

        // Substeps prevent a quick finger movement from tunnelling through walls.
        let segmentLength = max(ballRadius * 0.45, 1)
        let steps = max(1, Int(ceil(distance / segmentLength)))
        let delta = CGVector(dx: displacement.dx / CGFloat(steps),
                             dy: displacement.dy / CGFloat(steps))
        for _ in 0..<steps {
            let candidate = CGPoint(x: ball.position.x + delta.dx,
                                    y: ball.position.y + delta.dy)
            if isBlocked(at: candidate) {
                resetAfterCollision()
                return
            }
            ball.position = candidate
            if isGoal(at: candidate) {
                finishLevel()
                return
            }
        }
        updateWallSound()
    }

    /// VoiceOver action makes a *short* nudge, never jumps a full cell.
    func nudgeBall(horizontal: Int, vertical: Int) {
        guard abs(horizontal) + abs(vertical) == 1 else { return }
        joystickNeedsRelease = false
        moveBall(by: CGVector(dx: CGFloat(horizontal) * tileWidth * 0.08,
                              dy: CGFloat(vertical) * tileWidth * 0.08))
        if !joystickNeedsRelease && !gameFinished {
            HapticManager.ballMoving()
            audioPlayer?.playStepCue(volume: proximityVolume())
        }
    }

    /// The joystick calls this from its display timer.
    func steer(horizontal: CGFloat, vertical: CGFloat, deltaTime: CGFloat) {
        guard !joystickNeedsRelease, !gameFinished else { return }
        let magnitude = hypot(horizontal, vertical)
        guard magnitude > 0.04 else {
            // Maintain the sound level while the stick is held still,
            // allowing the player to listen to the nearest wall.
            if isMovementSoundPlaying { updateWallSound() }
            return
        }
        beginMovementSound()
        let factor = min(magnitude, 1)
        // About 0.8 cell per second at full deflection; less when gently held.
        let speed = tileWidth * 0.8 * factor
        moveBall(by: CGVector(dx: horizontal / magnitude * speed * deltaTime,
                              dy: vertical / magnitude * speed * deltaTime))
    }

    func releaseJoystick() {
        joystickNeedsRelease = false
        stopMovementSound()
    }

    private func isBlocked(at point: CGPoint) -> Bool {
        let half = sizeConst / 2
        let radius = ballRadius
        // Check the circle's four corners against all tile rectangles.
        let offsets: [CGPoint] = [
            CGPoint(x: -radius, y: -radius), CGPoint(x: radius, y: -radius),
            CGPoint(x: -radius, y: radius), CGPoint(x: radius, y: radius)
        ]
        for offset in offsets {
            let sampleX = point.x + offset.x
            let sampleY = point.y + offset.y
            if sampleX < -half || sampleX > half || sampleY < -half || sampleY > half {
                return true
            }
            let column = Int(floor((sampleX + half) / tileWidth))
            let row = Int(floor((sampleY + half) / tileWidth))
            guard mazeTiles.indices.contains(row),
                  mazeTiles[row].indices.contains(column),
                  mazeTiles[row][column] != 0 else { return true }
        }
        return false
    }

    private func isGoal(at point: CGPoint) -> Bool {
        let goalPosition = CGPoint(
            x: mazeOffset + CGFloat(goal.column) * tileWidth,
            y: mazeOffset + CGFloat(goal.row) * tileWidth
        )
        return hypot(point.x - goalPosition.x, point.y - goalPosition.y) < tileWidth * 0.32
    }

    private func resetAfterCollision() {
        guard !gameFinished else { return }
        joystickNeedsRelease = true
        touchIsDragging = false
        lastTouchLocation = nil
        stopMovementSound()
        HapticManager.collisionOccurred()
        run(SKAction.playSoundFileNamed("wall.mp3", waitForCompletion: false))
        ball.position = initialPosition ?? .zero
        onCollision?()
    }

    private func beginMovementSound() {
        if !isMovementSoundPlaying {
            audioPlayer?.moveSound(volume: 0.01)
            isMovementSoundPlaying = true
        }
        updateWallSound()
    }

    private var isMovementSoundPlaying = false
    private var lastWallHaptic = Date.distantPast

    private func updateWallSound() {
        guard isMovementSoundPlaying, ball != nil else { return }
        let closeness = wallCloseness()
        audioPlayer?.updateVolume(volume: proximityVolume())

        // Near-wall taps become faster as the ball approaches a surface.
        // They complement the rising audio without exposing directions.
        if closeness >= 0.82 {
            let interval = 0.5 - Double(closeness) * 0.3
            let now = Date()
            if now.timeIntervalSince(lastWallHaptic) >= interval {
                HapticManager.ballMoving()
                lastWallHaptic = now
            }
        }
    }

    private func wallCloseness() -> CGFloat {
        guard ball != nil, tileWidth > 0 else { return 0 }
        // Subtract ball radius: measure the gap between its edge and a wall.
        // Corridor centre (~0.38 tile clearance) is intentionally silent.
        let clearance = max(0, closestBlackTile(to: ball) - ballRadius)
        let soundRange = tileWidth * 0.36
        return max(0, min(1, (soundRange - clearance) / soundRange))
    }

    private func proximityVolume() -> Float {
        let closeness = wallCloseness()
        return Float(0.005 + closeness * closeness * 0.7)
    }

    private func stopMovementSound() {
        if isMovementSoundPlaying {
            audioPlayer?.stopAudio()
            isMovementSoundPlaying = false
        }
    }

    private func finishLevel() {
        guard !gameFinished else { return }
        gameFinished = true
        stopMovementSound()
        HapticManager.ballWin()
        run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        if appState.tutorialStage == nil,
           appState.topLevel <= appState.gameLevel,
           appState.topLevel < appState.gameLevel.lastLevel {
            appState.topLevel = appState.gameLevel.nextLevel()
        }
        appState.state = .win
    }

    // MARK: Direct touch dragging

    private func trySelectBall(at point: CGPoint) {
        let selectionRadius = max(ballRadius * 2.5, 30)
        guard !touchIsDragging, !ballFoundDuringTouch,
              hypot(point.x - ball.position.x, point.y - ball.position.y) <= selectionRadius else {
            return
        }
        ballFoundDuringTouch = true
        lastTouchLocation = point
        touchIsDragging = true
        joystickNeedsRelease = false
        HapticManager.ballTouched()
        run(SKAction.playSoundFileNamed("bonus.mp3", waitForCompletion: false))
        beginMovementSound()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !gameFinished, let touch = touches.first else { return }
        let point = touch.location(in: fatherTile)
        ballFoundDuringTouch = false
        trySelectBall(at: point)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let position = touch.location(in: fatherTile)
        if !touchIsDragging {
            // Finger-sweep exploration: announce discovery only when the
            // finger reaches the ball, without revealing its coordinates.
            trySelectBall(at: position)
            return
        }
        guard let previous = lastTouchLocation else { return }
        lastTouchLocation = position
        moveBall(by: CGVector(dx: position.x - previous.x,
                              dy: position.y - previous.y))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchIsDragging = false
        lastTouchLocation = nil
        ballFoundDuringTouch = false
        joystickNeedsRelease = false
        stopMovementSound()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    // MARK: Collisions

    func ballCollideWithBlock(ball: SKShapeNode, block: SKShapeNode) {
        resetAfterCollision()
    }

    func ballCollideWithWin(ball: SKShapeNode, block: SKShapeNode) {
        finishLevel()
    }
}
