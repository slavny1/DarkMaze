//
//  AppFlowView.swift
//  DarkMaze
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI

struct AppFlowView: View {

    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            if !appState.isOnboarding {
                TabOnboardingView()
            } else {
                if appState.state == .game {
                    GameView().id(appState.gameID)
                        .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.3)))
                } else if appState.state == .main {
                    MainView()
                        .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.3)))
                } else if appState.state == .win {
                    WinView()
                        .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.3)))
                } else if appState.state == .level {
                    LevelsListView()
                        .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.3)))
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    
    @ObservedObject static var appState = AppState()
    
    static var previews: some View {
        AppFlowView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(appState)
            .background(Color.black)
            .ignoresSafeArea()
    }
}
