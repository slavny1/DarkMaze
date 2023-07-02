//
//  TileNode.swift
//
//
//  Created by Viacheslav on 13/04/23.
//

import Foundation
import SpriteKit

final class TileNode: SKShapeNode {
    private enum Constants {
        static let lineWidth: CGFloat = 1
    }

    // Naming: Kind
    enum TileType {
        case wall
        case gray
        case win
        case black
        case none

        var fillColor: UIColor {
            switch self {
            case .wall:
                return .black
            case .gray:
                return .gray
            case .black:
                return .black
            case .win:
                return .white
            case .none:
                return .clear
            }
        }
    }

    var type: TileType = .none {
        didSet {
            // move to func
            strokeColor = .white
            lineWidth = Constants.lineWidth
            fillColor = type.fillColor
        }
    }
}
