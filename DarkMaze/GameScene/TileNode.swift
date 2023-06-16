//
//  TileNode.swift
//
//
//  Created by Viacheslav on 13/04/23.
//

import Foundation
import SpriteKit

class TileNode: SKShapeNode {

    enum TileType {
        case wall
        case gray
        case win
        case black
        case none
    }

    var type: TileType? = nil {
        didSet {
            self.strokeColor = .white
            self.lineWidth = 1
            if let type = type {
                switch type {
                case .wall:
                    self.fillColor = .black
                case .gray:
                    self.fillColor = .gray
                case .black:
                    self.fillColor = .black
                case .win:
                    self.fillColor = .white
                case .none:
                    self.fillColor = .clear
                }
            }
        }
    }
}
