//
//  ExDistance.swift
//  Dark Maze
//
//  Created by Viacheslav on 17/04/23.
//

import Foundation
import SpriteKit

extension GameScene {

//    func distance(from ball: SKShapeNode, to tile: SKShapeNode) -> CGFloat {
//        let xDistance = ball.position.x - tile.position.x
//        let yDistance = ball.position.y - tile.position.y
//        return sqrt(xDistance * xDistance + yDistance * yDistance)
//    }

    func distance(from ball: SKShapeNode, to tile: SKShapeNode) -> CGFloat {

        let halfTileWidth = tile.frame.width / 2

        let ballCenter = ball.position
        let tileCenter = tile.position

        let closestX = max(tileCenter.x - halfTileWidth, min(ballCenter.x, tileCenter.x + halfTileWidth))
        let closestY = max(tileCenter.y - halfTileWidth, min(ballCenter.y, tileCenter.y + halfTileWidth))

        let xDistance = ballCenter.x - closestX
        let yDistance = ballCenter.y - closestY

        return sqrt(xDistance * xDistance + yDistance * yDistance)
    }

    func edgeDistance(to ball: SKShapeNode) -> CGFloat {

        let mazeHalfWidth = fatherTile.frame.size.width / 2

        let xEdgeDistance = mazeHalfWidth - abs(ball.position.x)
        let yEdgeDistance = mazeHalfWidth - abs(ball.position.y)

        return min(xEdgeDistance, yEdgeDistance)
    }

    func closestBlackTile(to ball: SKShapeNode) -> CGFloat {
        var closestDistance: CGFloat = edgeDistance(to: ball)

        fatherTile.children.forEach { child in
            if let blackNode = child as? TileNode  {
                if blackNode.type == .wall {
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
