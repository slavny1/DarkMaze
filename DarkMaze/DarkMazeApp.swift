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
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environmentObject(appState)
            }
        }
    }
}

