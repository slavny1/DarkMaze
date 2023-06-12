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

    func nextLevel() -> GameLevel {
            switch gameLevel {
            case .zero:
                return .one
            case .one:
                return .two
            case .two:
                return .three
            case .three:
                return .zero
            }
        }

    enum GameLevel: Int {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
    }

    @Published var state: GameState = .main
    @Published var gameLevel: GameLevel = .zero
    @Published var gameID = UUID()
}
