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

    // Spoken status is exposed by a SwiftUI accessibility element.
    var onStatusChange: ((String) -> Void)?

    private let sizeConst: CGFloat = UIScreen.main.bounds.width - 2 * Constants.borderLineWidth

    private var closestDistance: CGFloat = CGFloat.infinity //
    private var distanceToNode: CGFloat? // standart distance from ball to node

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
        createFather()
        createMaze()
        createBall()
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

        // Define distance from ball to the center of node
        distanceToNode = CGFloat(tileWidth / 2)

        for row in 0..<mazeLevelOne.count {
            for column in 0..<mazeLevelOne[row].count {
                let tile = TileNode(rectOf: .init(width: tileWidth, height: tileWidth))
                tile.type = appState.blindMode ? .black : .gray

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
        // In the future radius should change dependig on size of a tile and maze
        ball = SKShapeNode(circleOfRadius: fatherTile.frame.width / 20)
        ball.fillColor = .white
        // Ball's ohysics body will change too depending on complexity of game (the more the harder)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.width / 10)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.block | PhysicsCategory.win
        ball.physicsBody?.collisionBitMask = PhysicsCategory.none
        ball.position = initialPosition!
        fatherTile.addChild(ball)
    }

    // MARK: Accessible directions / joystick

    /// Move one cell from the current position. Used by visible joystick
    /// buttons and VoiceOver custom actions; no dragging is required.
    func moveBall(dx: Int, dy: Int) {
        guard !gameFinished, let ball, tileWidth > 0,
              abs(dx) + abs(dy) == 1 else { return }

        let column = Int(round((ball.position.x - mazeOffset) / tileWidth))
        let row = Int(round((ball.position.y - mazeOffset) / tileWidth))
        let nextColumn = column + dx
        let nextRow = row + dy

        guard mazeTiles.indices.contains(nextRow),
              mazeTiles[nextRow].indices.contains(nextColumn),
              mazeTiles[nextRow][nextColumn] != 0 else {
            HapticManager.collisionOccurred()
            run(SKAction.playSoundFileNamed("wall.mp3", waitForCompletion: false))
            onStatusChange?("Wall. Choose another direction.")
            return
        }

        ball.position = CGPoint(
            x: mazeOffset + CGFloat(nextColumn) * tileWidth,
            y: mazeOffset + CGFloat(nextRow) * tileWidth
        )
        HapticManager.ballMoving()

        if nextRow == goal.row && nextColumn == goal.column {
            finishLevel()
        } else {
            onStatusChange?("Moved. Row \(nextRow + 1), column \(nextColumn + 1).")
        }
    }

    private func finishLevel() {
        guard !gameFinished else { return }
        gameFinished = true
        audioPlayer?.stopAudio()
        HapticManager.ballWin()
        run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        onStatusChange?("Goal reached!")
        if appState.tutorialStage == nil,
           appState.topLevel <= appState.gameLevel,
           appState.topLevel < appState.gameLevel.lastLevel {
            appState.topLevel = appState.gameLevel.nextLevel()
        }
        appState.state = .win
    }

    // MARK: Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: fatherTile)
        if ball.frame.contains(touchLocation) {
            lastTouchLocation = touchLocation
            print("Ball tapped")
            HapticManager.ballTouched()
            audioPlayer?.moveSound(volume: volume)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: fatherTile)

        // define closest distance as closest black tile to ball
        closestDistance = closestBlackTile(to: ball)

        // change volume depends on a distance from the edge or black tile 
        // (const 10 is for reducing volume of moving ball compare with collision sounds)
        // if wall or edge more than half tile size volume is constant
        volume = closestDistance < distanceToNode! ? Float((distanceToNode! - closestDistance) / 20) : 0.01
        audioPlayer?.updateVolume(volume: volume)
        // I need this for a haptic feedback in order to find ball at the first play. User can scan maze with finger and find where the ball is.
        if lastTouchLocation == nil && ball.frame.contains(touchLocation) {
            HapticManager.ballTouched()
            //            run(SKAction.playSoundFileNamed("bonus.mp3", waitForCompletion: false))
            //            audioPlayer?.play()
        }
        guard lastTouchLocation != nil else { return }

        // if ball whent of edges of the maze more than a half
        guard ball.position.x > -fatherTile.frame.width / 2,
              ball.position.y > -fatherTile.frame.height / 2,
              ball.position.x < fatherTile.frame.width / 2,
              ball.position.y < fatherTile.frame.height / 2 else {
            // return ball to the initial position in case it fell out of the border
            ball.position = initialPosition!
            HapticManager.collisionOccurred()
            run(SKAction.playSoundFileNamed("edge.mp3", waitForCompletion: false))
            lastTouchLocation = nil
            return
        }

        // Ball moving
        HapticManager.ballMoving()
        ball.position = touchLocation
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        audioPlayer?.stopAudio()
        lastTouchLocation = nil
        print(closestDistance)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

        audioPlayer?.stopAudio()
        lastTouchLocation = nil
    }

    // MARK: Collisions

    func ballCollideWithBlock(ball: SKShapeNode, block: SKShapeNode) {
        print("Collision detected")
        ball.removeFromParent()
        block.fillColor = .red

        // Delay the execution of the color revert by one second
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Revert the block color back to the original color
            block.fillColor = .black
        }
        
        HapticManager.collisionOccurred()

        audioPlayer?.stopAudio()
        run(SKAction.playSoundFileNamed("wall.mp3", waitForCompletion: false))
        lastTouchLocation = nil
        print(closestDistance)
        createBall()
    }

    func ballCollideWithWin(ball: SKShapeNode, block: SKShapeNode) {
        finishLevel()
    }
}
