//
//  ContentView.swift
//  DarkMaze
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI



struct ContentView: View {

    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            switch appState.state {
            case .game:
                GameView().id(appState.gameID)
            case .main:
                MainView()
            case .win:
                WinView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    
    @ObservedObject static var appState = AppState()
    
    static var previews: some View {
        ContentView()
            .environmentObject(appState)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
