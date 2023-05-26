//
//  AppState.swift
//  DarkMaze
//
//  Created by Viacheslav on 26/05/23.
//

import Foundation

final class AppState: ObservableObject {
    enum GameState {
        case main, game, win
    }

    @Published var state: GameState = .main
    @Published var gameID = UUID()
}
