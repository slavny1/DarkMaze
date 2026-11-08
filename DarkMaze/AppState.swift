//
//  AppState.swift
//  DarkMaze
//
//  Created by Viacheslav on 26/05/23.
//

import Foundation

final class AppState: ObservableObject {
    @Published var state: GameState = .main
    @Published var gameLevel: GameLevel = .zero
    @Published var gameID = UUID()
    // 0...2 is a guided, deterministic maze; nil is the regular game.
    @Published var tutorialStage: Int?

    @Published var isOnboarding = true {
        didSet {
            UserDefaults.standard.set(isOnboarding, forKey: "isOnboarding")
        }
    }

    @Published var blindMode = false {
        didSet {
            UserDefaults.standard.set(blindMode, forKey: "blindMode")
        }
    }

    @Published var topLevel: GameLevel {
        didSet {
            UserDefaults.standard.set(topLevel.rawValue, forKey: "topLevel")
        }
    }

    func startTutorial() {
        tutorialStage = 0
        gameID = UUID()
        isOnboarding = false
        state = .game
    }

    func startRegularGame(level: GameLevel) {
        tutorialStage = nil
        gameLevel = level
        gameID = UUID()
        state = .game
    }

    init() {
        self.topLevel = .init(rawValue: UserDefaults.standard.integer(forKey: "topLevel")) ?? .zero
        self.blindMode = UserDefaults.standard.bool(forKey: "blindMode")
        // Show accessible introduction on a truly fresh install.
        // Preserve the choice of returning players.
        if UserDefaults.standard.object(forKey: "isOnboarding") == nil {
            self.isOnboarding = true
        } else {
            self.isOnboarding = UserDefaults.standard.bool(forKey: "isOnboarding")
        }

    }
}

// MARK: GameState

extension AppState {
    enum GameState {
        case main, game, win, level, signals
    }
}

// MARK: GameLevel

extension AppState {
    enum GameLevel: Int, CaseIterable, Comparable {
        static func < (lhs: AppState.GameLevel, rhs: AppState.GameLevel) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        case zero
        case one
        case two
        case three

        var isLastLevel: Bool { self == lastLevel }
        var lastLevel: Self { .three }

        func nextLevel() -> GameLevel {
            return Self(rawValue: self.rawValue + 1) ?? .three
        }
    }
}
