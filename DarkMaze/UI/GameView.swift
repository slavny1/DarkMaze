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
    
    var scene: SKScene {
        let scene = GameScene(appState: appState,
                              size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
        scene.scaleMode = .aspectFit
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene, transition: nil)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button {
                        appState.state = .level
                    } label: {
                        Text("LEVEL \(appState.gameLevel.rawValue)")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .black, design: .monospaced))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        appState.state = .main
                    } label: {
                        HStack {
                            Image(systemName: "chevron.backward")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                            Text("Main")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .black, design: .monospaced))
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 25) {
                        Button {
                            appState.gameID = UUID()
                        } label: {
                            HStack {
                                Text("Reset")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .black, design: .monospaced))
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                            }
                        }
                    }
                }
            }
    }
}
