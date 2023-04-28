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
        case black
        case gray
    }

    var type: TileType? = nil {
        didSet {
            self.strokeColor = .white
            self.lineWidth = 1
            if let type = type {
                switch type {
                case .black:
                    self.fillColor = .black
                case .gray:
                    self.fillColor = .black
                }
            }
        }
    }
}
