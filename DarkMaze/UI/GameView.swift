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

    @Binding var state: GameState

    var scene: SKScene {
        let scene = GameScene()
        scene.scaleMode = .aspectFit
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        return scene
    }

    var body: some View {
        VStack {
            HStack {
                Button {
                    //reset game
                } label: {
                    Text("Reset")
                }
                Button {
                    state = .main
                } label: {
                    Text("Main")
                }
            }

            SpriteView(scene: scene, transition: nil)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            //            .padding()
            //            .ignoresSafeArea()
        }
    }

}
