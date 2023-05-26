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
            Text("LEVEL 1")
                .foregroundColor(.white)
                .font(.system(size: 32, weight: .black, design: .monospaced))
            HStack(spacing: 25) {
                Button {
                    let resetGame = GameScene()
                    resetGame.resetGame()
                } label: {
                    Text("Reset")
                        .frame(width: 150, height: 50)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                }
                Button {
                    state = .main
                } label: {
                    Text("Main")
                        .frame(width: 150, height: 50)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .border(.white, width: 4)
                }
            }
            .padding(.bottom, 50)

            SpriteView(scene: scene, transition: nil)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            //            .padding()
            //            .ignoresSafeArea()
        }
    }

}
