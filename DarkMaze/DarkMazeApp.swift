//
//  DarkMazeApp.swift
//  DarkMaze
//
//  Created by Viacheslav on 28/04/23.
//

import SwiftUI

@main
struct DarkMazeApp: App {

    @ObservedObject var appState = AppState()
    @State private var currentTab = 1

    var body: some Scene {
        WindowGroup {
            if appState.isOnboarding {
                TabView(selection: $currentTab,
                        content:  {
                    ForEach(OnboardingData.list) { viewData in
                        OnboardingView(data: viewData)
                            .tag(viewData.id)
                    }
                })
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            } else {
                NavigationView {
                    ContentView()
                        .environmentObject(appState)
                }
            }
        }
    }
}

