//
//  RectView.swift
//  DarkMaze
//
//  Created by Viacheslav on 08/04/23.
//

import Foundation
import SwiftUI
import SpriteKit

struct GameView: View {

    var scene: SKScene {
        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .aspectFill
        return scene
    }

    var body: some View {
        SpriteView(scene: scene, transition: nil)
            .edgesIgnoringSafeArea(.all)
    }

}
