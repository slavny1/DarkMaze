//
//  ContentView.swift
//  DarkMaze
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI

enum GameState {
    case main, game, win
}

struct ContentView: View {
    @State var state: GameState = .main
    var body: some View {
        ZStack {
            switch state {
            case .game:
                GameView(state: $state)
            case .main:
                MainView(state: $state)
            case .win:
                WinView(state: $state)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
