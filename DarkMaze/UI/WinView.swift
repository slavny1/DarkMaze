//
//  WinView.swift
//  DarkMaze
//
//  Created by Viacheslav on 25/05/23.
//

import SwiftUI

struct WinView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .center) {
            Text("WIN")
                .foregroundColor(.white)
                .font(.system(size: 124, weight: .black, design: .monospaced))

            Button {
                appState.gameID = UUID()
                appState.state = .game
            } label: {
                Text("Play again")
                    .frame(width: 250, height: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
            }

            Button {
                if let stage = appState.tutorialStage {
                    if stage < 2 {
                        appState.tutorialStage = stage + 1
                        appState.gameID = UUID()
                        appState.state = .game
                    } else {
                        appState.tutorialStage = nil
                        appState.state = .main
                    }
                } else {
                    appState.gameLevel = appState.gameLevel.nextLevel()
                    appState.gameID = UUID()
                    appState.state = .game
                }
            } label: {
                Text(appState.tutorialStage == nil ? "Next level" :
                     (appState.tutorialStage == 2 ? "Finish tutorial" : "Next tutorial"))
                    .frame(width: 250, height: 50)
                    .background(Color.black)
                    .foregroundColor(appState.tutorialStage == nil && appState.gameLevel.isLastLevel ? .gray : .white)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .border(appState.tutorialStage == nil && appState.gameLevel.isLastLevel ? .gray : .white, width: 4)
            }
            .disabled(appState.tutorialStage == nil && appState.gameLevel.isLastLevel)

            Button {
                appState.tutorialStage = nil
                appState.state = .main
            } label: {
                Text("Back to main")
                    .frame(width: 250, height: 50)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .black, design: .monospaced))
            }
        }
    }
}

struct WinView_Previews: PreviewProvider {
    static var previews: some View {
        WinView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            .environmentObject(AppState.init())
    }
}
