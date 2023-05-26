//
//  File.swift
//  Dark Maze
//
//  Created by Viacheslav on 17/04/23.
//

import Foundation
import SpriteKit

class WinScene: SKScene {

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        let winNode = SKSpriteNode(imageNamed: "win")
        winNode.position = CGPoint(x: size.width / 2, y: size.height / 2 + 100)

        let resetButton = SKLabelNode(text: "Play again")
        resetButton.fontSize = 32
        resetButton.fontColor = .white
        resetButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        resetButton.name = "resetButton"

        addChild(winNode)
        addChild(resetButton)
        run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let nodes = self.nodes(at: location)
            for node in nodes {
                if node.name == "resetButton" {
                    resetGame()
                }
            }
        }
    }

    private func resetGame() {
        let transition = SKTransition.fade(withDuration: 1.0)
        let gameScene = GameScene(size: size)
        self.view?.presentScene(gameScene, transition: transition)
    }

}
