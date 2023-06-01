//
//  GameScene.swift
//  DarkMaze
//
//  Created by Viacheslav on 08/04/23.
//

import Foundation
import SpriteKit
import UIKit
import AVFoundation

class GameScene: SKScene {

    var appState: AppState?

    private var lastTouchLocation: CGPoint?
    private var initialPosition: CGPoint? // position for ball
//    var finalPosition: CGPoint?

    private var closestDistance: CGFloat = CGFloat.infinity //
    private var distanceToNode: CGFloat? // standart distance from ball to node

    private var ball: SKShapeNode!
    var fatherTile: SKShapeNode!

    private var audioPlayer: AVAudioPlayer?
    private var volume: Float = 0

    private let tapFeedbackBallTouched = UIImpactFeedbackGenerator(style: .heavy)
    private let tapFeedbackBallFound = UIImpactFeedbackGenerator(style: .light)
    private let tapFeedbackBallMoving = UISelectionFeedbackGenerator()
    private let tapFeedbackCollision = UINotificationFeedbackGenerator()

    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let all: UInt32 = UInt32.max
        static let ball: UInt32 = 0b1
        static let block: UInt32 = 0b10
        static let win: UInt32 = 0b100
    }

    override func didMove(to view: SKView) {
        createFather()
        createMaze()
        createBall()
        moveSound(volume: volume)

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    private func createFather() {
        guard let view = view else { return }
        fatherTile = SKShapeNode(rectOf: .init(width: view.frame.width, height: view.frame.width))
        fatherTile.fillColor = .clear
        fatherTile.strokeColor = .clear
        fatherTile.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(fatherTile)
    }

    // MARK: Maze creation

    private func createMaze() {
        let mazeLevelOne = MazeLibrary.mazes.randomElement()!

        // Define size of a tile
        let tileWidth = Int(fatherTile.frame.size.width) / mazeLevelOne.count

        // Define an offset for the first tile in a maze
        let mazeOffset = CGFloat(tileWidth / 2) - fatherTile.frame.width / 2 + fatherTile.lineWidth

        // Set a position for the ball
        initialPosition = CGPoint(x: mazeOffset, y: mazeOffset)

        // Define distance from ball to the center of node
        distanceToNode = fatherTile.frame.width / CGFloat(mazeLevelOne.count) / 2 - fatherTile.lineWidth

        for row in 0..<mazeLevelOne.count {
            for column in 0..<mazeLevelOne[row].count {
                let tile = TileNode(rectOf: .init(width: tileWidth, height: tileWidth))
                tile.type = .gray // define it's as gray if I need to test - the open nodes will be gray color
                tile.strokeColor = .white
                tile.lineWidth = 1

                // define position of a tile
                tile.position = CGPoint(x: Int(mazeOffset) + column * tileWidth, y: Int(mazeOffset) + row * tileWidth)

                // If matrix number is == 0 then its BLOCK
                if mazeLevelOne[row][column] == 0 {
                    tile.type = .black
                    tile.physicsBody = SKPhysicsBody(rectangleOf: tile.frame.size)
                    tile.physicsBody?.isDynamic = true
                    tile.physicsBody?.categoryBitMask = PhysicsCategory.block
                    tile.physicsBody?.contactTestBitMask = PhysicsCategory.ball
                    tile.physicsBody?.collisionBitMask = PhysicsCategory.none
                }

                // For the last tile -- WIN
                if (row == mazeLevelOne.count - 1) && (column == mazeLevelOne[row].count - 1) {
                    tile.fillColor = .white
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

    // MARK: Moving music

    private func moveSound(volume: Float) {

        guard let url = Bundle.main.url(forResource: "ufo", withExtension: "mp3") else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.enableRate = true
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = volume
        } catch let error {
            print(error.localizedDescription)
        }
    }

    // MARK: Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: fatherTile)
        if ball.frame.contains(touchLocation) {
            lastTouchLocation = touchLocation
            print("Ball tapped")
            tapFeedbackBallTouched.impactOccurred()
            audioPlayer?.play()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let touchLocation = touch.location(in: fatherTile)

        // define closest distance as closest black tile to ball
        closestDistance = closestBlackTile(to: ball)

        //change volume (need to reconsider constant in the second part of equation)
        audioPlayer?.volume = Float((distanceToNode! - closestDistance) / 10)
        print(audioPlayer?.volume as Any)
        if lastTouchLocation == nil && ball.frame.contains(touchLocation) {
            tapFeedbackBallTouched.impactOccurred()
//            run(SKAction.playSoundFileNamed("bonus.mp3", waitForCompletion: false))
            audioPlayer?.play()
        }
        guard lastTouchLocation != nil else { return }

        guard ball.position.x > -fatherTile.frame.width / 2,
              ball.position.y > -fatherTile.frame.height / 2,
              ball.position.x < fatherTile.frame.width / 2,
              ball.position.y < fatherTile.frame.height / 2 else {
            // return ball to the initial position in case it fell out of the border
            ball.position = initialPosition!
            tapFeedbackCollision.notificationOccurred(.warning)
            run(SKAction.playSoundFileNamed("edge.mp3", waitForCompletion: false))
            lastTouchLocation = nil
            return
        }

        // Ball moving
        tapFeedbackBallMoving.selectionChanged()
        ball.position = touchLocation
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        audioPlayer?.stop()
        lastTouchLocation = nil
        print(closestDistance)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        audioPlayer?.stop()
        lastTouchLocation = nil
    }

    // MARK: Collisions

    func ballCollideWithBlock(ball: SKShapeNode, block: SKShapeNode) {
        print("Collision detected")
        ball.removeFromParent()
        block.fillColor = .red
        tapFeedbackCollision.notificationOccurred(.error)
        audioPlayer?.stop()
        run(SKAction.playSoundFileNamed("wall.mp3", waitForCompletion: false))
        lastTouchLocation = nil
//        print(closestDistance)
        createBall()
    }

    func ballCollideWithWin(ball: SKShapeNode, block: SKShapeNode) {
        print("Win detected")
        audioPlayer?.stop()
        run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        appState?.state = .win
    }
}
