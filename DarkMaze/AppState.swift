//
//  AppState.swift
//  DarkMaze
//
//  Created by Viacheslav on 26/05/23.
//

import Foundation

final class AppState: ObservableObject {

    enum GameState {
        case main, game, win, level
    }

    enum GameLevel: Int, CaseIterable {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3

        func nextLevel() -> GameLevel {
            return Self(rawValue: self.rawValue + 1) ?? .three
        }

    }

    @Published var state: GameState = .main
    @Published var gameLevel: GameLevel = .zero
    @Published var gameID = UUID()

    @Published var isOnboarding = true

    @Published var blindMode: Bool = false {
        didSet {
            UserDefaults.standard.set(topLevel, forKey: "blindMode")
        }
    }

    @Published var topLevel: Int = 0 {
        didSet {
            UserDefaults.standard.set(topLevel, forKey: "topLevel")
            gameLevel = GameLevel(rawValue: topLevel) ?? .zero
        }
    }

    init() {
        self.topLevel = UserDefaults.standard.integer(forKey: "topLevel")
        self.blindMode = UserDefaults.standard.bool(forKey: "blindMode")
        self.gameLevel = GameLevel(rawValue: topLevel) ?? .zero
    }
}
