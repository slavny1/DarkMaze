//
//  ContentView.swift
//  DarkMaze
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI



struct ContentView: View {

    @EnvironmentObject var appState: AppState
    @State var blindMode = false

    var body: some View {
        NavigationView {

            switch appState.state {
            case .game:
                GameView(blindMode: $blindMode).id(appState.gameID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .ignoresSafeArea()
            case .main:
                MainView(blindMode: $blindMode)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .ignoresSafeArea()
            case .win:
                WinView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .ignoresSafeArea()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    @ObservedObject static var appState = AppState()
    
    static var previews: some View {
        ContentView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(appState)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
