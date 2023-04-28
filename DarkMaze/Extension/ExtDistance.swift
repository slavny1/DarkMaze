//
//  ExDistance.swift
//  Dark Maze
//
//  Created by Viacheslav on 17/04/23.
//

import Foundation
import SpriteKit

extension GameScene {

    func distance(from ball: SKShapeNode, to tile: SKShapeNode) -> CGFloat {
        let xDistance = ball.position.x - tile.position.x
        let yDistance = ball.position.y - tile.position.y
        return sqrt(xDistance * xDistance + yDistance * yDistance)
    }

    func closestBlackTile(to ball: SKShapeNode) -> CGFloat {
        var closestDistance: CGFloat = CGFloat.infinity
        fatherTile.children.forEach { child in
            if let blackNode = child as? TileNode  {
                if blackNode.type == .black {
                    let distanceToBall = distance(from: ball, to: blackNode)
                    if distanceToBall < closestDistance {
                        closestDistance = distanceToBall
                    }
                }
            }
        }
        return closestDistance
    }
}
