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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("LEVEL \(appState.gameLevel.rawValue)")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .black, design: .monospaced))
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
