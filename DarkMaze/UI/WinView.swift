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

        let isLastLevel = appState.gameLevel.rawValue == AppState.GameLevel.allCases.last?.rawValue ?? 3

        VStack(alignment: .center) {
            Text("WIN")
                .foregroundColor(.white)
                .font(.system(size: 124, weight: .black, design: .monospaced))

            Button {
                appState.state = .game
            } label: {
                Text("Play again")
                    .frame(width: 250, height: 50)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
            }

            Button {

                appState.state = .game
                appState.gameLevel = appState.gameLevel.nextLevel()
                
            } label: {
                Text("Next level")
                    .frame(width: 250, height: 50)
                    .background(Color.black)
                    .foregroundColor(isLastLevel ? .gray : .white)
                    .font(.system(size: 24, weight: .black, design: .monospaced))
                    .border(isLastLevel ? .gray : .white, width: 4)
            }
            .disabled(isLastLevel)

            Button {
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
