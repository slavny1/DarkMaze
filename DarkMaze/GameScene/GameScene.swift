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

    var lastTouchLocation: CGPoint?
    var initialPosition: CGPoint?
    var finalPosition: CGPoint?
    var ball: SKShapeNode!
    var fatherTile: SKShapeNode!
    var audioPlayer: AVAudioPlayer?
    var closestDistance: CGFloat = CGFloat.infinity
    var volume: Float = 0

    var distanceToNode: CGFloat?

    let tapFeedbackBallTouched = UIImpactFeedbackGenerator(style: .heavy)
    let tapFeedbackBallFound = UIImpactFeedbackGenerator(style: .light)
    let tapFeedbackBallMoving = UISelectionFeedbackGenerator()
    let tapFeedbackCollision = UINotificationFeedbackGenerator()

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
//        createReset()
        moveSound(volume: volume)
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
    }

    func createFather() {
        guard let view = view else { return }
        fatherTile = SKShapeNode(rectOf: .init(width: view.frame.width, height: view.frame.width))
        fatherTile.fillColor = .clear
        fatherTile.strokeColor = .clear
        fatherTile.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(fatherTile)
    }

//    func createReset() {
//        let resetLabel = SKLabelNode(text: "Restart")
//        resetLabel.fontSize = 32
//        resetLabel.fontColor = .white
//        resetLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + fatherTile.frame.height / 2 + 50)
//        resetLabel.name = "resetLabel"
//        addChild(resetLabel)
//    }

    func createMaze() {
        let mazeLevelOne = MazeLibrary.mazes.randomElement()!
        let tileWidth = (Int(fatherTile.frame.size.width)) / mazeLevelOne.count
        let mazeOffset = CGFloat(tileWidth / 2) - fatherTile.frame.width / 2 + fatherTile.lineWidth - 2
        initialPosition = CGPoint(x: mazeOffset, y: mazeOffset)
        distanceToNode = fatherTile.frame.width / CGFloat(mazeLevelOne.count)
        for row in 0..<mazeLevelOne.count {
            for column in 0..<mazeLevelOne[row].count {

                let tile = TileNode(rectOf: .init(width: tileWidth, height: tileWidth))
                tile.type = .gray
                tile.strokeColor = .white
                tile.lineWidth = 1
                tile.position = CGPoint(x: Int(mazeOffset) + column * (tileWidth), y: Int(mazeOffset) + row * (tileWidth))
                if mazeLevelOne[row][column] == 0 {
                    tile.type = .black
                    tile.physicsBody = SKPhysicsBody(rectangleOf: tile.frame.size)
                    tile.physicsBody?.isDynamic = true
                    tile.physicsBody?.categoryBitMask = PhysicsCategory.block
                    tile.physicsBody?.contactTestBitMask = PhysicsCategory.ball
                    tile.physicsBody?.collisionBitMask = PhysicsCategory.none
                }
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

    func createBall() {
        ball = SKShapeNode(circleOfRadius: fatherTile.frame.width / 20)
        ball.fillColor = .white
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.width / 10)
        ball.physicsBody?.isDynamic = true
        ball.physicsBody?.categoryBitMask = PhysicsCategory.ball
        ball.physicsBody?.contactTestBitMask = PhysicsCategory.block | PhysicsCategory.win
        ball.physicsBody?.collisionBitMask = PhysicsCategory.none
        ball.position = initialPosition!
        fatherTile.addChild(ball)
    }

    func moveSound(volume: Float) {

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

    //MARK: Touches

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: fatherTile)
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        if ball.frame.contains(touchLocation) {
            lastTouchLocation = touchLocation
            print("Ball tapped")
            tapFeedbackBallTouched.impactOccurred()
//            audioPlayer?.volume += 0.01
            audioPlayer?.play()
        }
//        for node in nodes {
//            if node.name == "resetLabel" {
//                resetGame()
//            }
//        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let touchLocation = touch.location(in: fatherTile)
        closestDistance = closestBlackTile(to: ball)
        audioPlayer?.volume = Float((distanceToNode! - closestDistance) / 15)
//        print(audioPlayer?.volume)
        if lastTouchLocation == nil && ball.frame.contains(touchLocation) {
            tapFeedbackBallTouched.impactOccurred()
            run(SKAction.playSoundFileNamed("bonus.mp3", waitForCompletion: false))
            audioPlayer?.play()
        }
        guard (lastTouchLocation != nil) else { return }
        guard ball.position.x > -fatherTile.frame.width / 2,
              ball.position.y > -fatherTile.frame.height / 2,
              ball.position.x < fatherTile.frame.width / 2,
              ball.position.y < fatherTile.frame.height / 2 else {
            ball.position = initialPosition!
            tapFeedbackCollision.notificationOccurred(.warning)
            run(SKAction.playSoundFileNamed("edge.mp3", waitForCompletion: false))
            lastTouchLocation = nil
            return
        }
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

    //MARK: Collisions

    func ballCollideWithBlock(ball: SKShapeNode, block: SKShapeNode) {
        print("Collision detected")
        ball.removeFromParent()
        block.fillColor = .red
        tapFeedbackCollision.notificationOccurred(.error)
        run(SKAction.playSoundFileNamed("wall.mp3", waitForCompletion: false))
        audioPlayer?.stop()
        lastTouchLocation = nil
        print(closestDistance)
        createBall()
    }

    func ballCollideWithWin(ball: SKShapeNode, block: SKShapeNode) {
        print("Win detected")
        audioPlayer?.stop()
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //        resetGame()
        let winScene = WinScene(size: self.size)
        view?.presentScene(winScene)
    }

    func resetGame() {
        removeAllChildren()
        didMove(to: view!)
    }
}
