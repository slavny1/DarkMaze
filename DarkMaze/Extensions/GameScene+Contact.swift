//
//  ExContact.swift
//  Dark Maze
//
//  Created by Viacheslav on 17/04/23.
//

import Foundation
import SpriteKit

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if (firstBody.categoryBitMask & PhysicsCategory.ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.win != 0) {
            if let ball = firstBody.node as? SKShapeNode,
               let win = secondBody.node as? SKShapeNode {
                ballCollideWithWin(ball: ball, block: win)
            }
        }

        if (firstBody.categoryBitMask & PhysicsCategory.ball != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.block != 0) {
            if let ball = firstBody.node as? SKShapeNode,
               let block = secondBody.node as? SKShapeNode {
                ballCollideWithBlock(ball: ball, block: block)
            }
        }
    }
}
