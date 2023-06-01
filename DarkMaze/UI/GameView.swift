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
    
    @EnvironmentObject var appState: AppState
    @Binding var blindMode: Bool
    
    var scene: SKScene {
        let scene = GameScene()
        scene.scaleMode = .aspectFit
        scene.appState = appState
        scene.blindMode = blindMode
        scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene, transition: nil)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LEVEL 1")
                        .foregroundColor(.white)
                        .font(.system(size: 32, weight: .black, design: .monospaced))
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        appState.state = .main
                    } label: {
                        Text("Exit")
//                            .frame(width: 150, height: 50)
//                            .background(Color.black)
                            .foregroundColor(.white)
                            .font(.system(size: 18, weight: .black, design: .monospaced))
//                            .border(.white, width: 4)
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    HStack(spacing: 25) {
                        Button {
                            appState.gameID = UUID()
                        } label: {
//                            Text("Reset")
//                                .frame(width: 150, height: 50)
//                                .background(Color.white)
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                        }
                        Button {
                            blindMode.toggle()
                        } label: {
                            Image(systemName: blindMode ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        }
                    }
                }
            }
    }
}
