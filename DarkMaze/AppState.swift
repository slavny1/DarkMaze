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

    @Published var isOnboarding = true {
        didSet {
//            storage.save(.onboarding, value: isOnboarding)
            UserDefaults.standard.set(isOnboarding, forKey: "isOnboarding")
        }
    }

    @Published var blindMode: Bool = false {
        didSet {
//            storage.save(.blindMode, value: blindMode)
            UserDefaults.standard.set(blindMode, forKey: "blindMode")
        }
    }

    @Published var topLevel: GameLevel {
        didSet {
//            storage.save(.topLevel, value: topLevel)
            UserDefaults.standard.set(topLevel, forKey: "topLevel")
        }
    }

//    var storage: Storage

    init() {
        self.topLevel = .init(rawValue: UserDefaults.standard.integer(forKey: "topLevel")) ?? .zero
        self.blindMode = UserDefaults.standard.bool(forKey: "blindMode")
        self.isOnboarding = UserDefaults.standard.bool(forKey: "isOnboarding")

//        storage = UserDefaultsStorage()
//        self.gameLevel = GameLevel(rawValue: topLevel) ?? .zero
    }
//
//    init(storage: Storage) {
//        self.topLevel = storage.getInt(.topLevel)
//        self.blindMode = storage.getBool(.blindMode)
//        self.isOnboarding = storage.getBool(.onboarding)
//
//        self.storage = storage
//    }
}

// Mark: GameState

extension AppState {
    enum GameState {
        case main, game, win, level
    }
}

// Mark: GameLevel

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

//enum StorageType: String {
//    case onboarding = "isOnboarding"
//    case blindMode = "blindMode"
//    case topLevel = "topLevel"
//}
//
//protocol Storage {
//    func getBool(_ type: StorageType) -> Bool
//    func getInt(_ type: StorageType) -> Int
//    func save<T>(_ type: StorageType, value: T)
//}
//
//struct UserDefaultsStorage: Storage {
//    func getBool(_ type: StorageType) -> Bool {
//        UserDefaults.standard.bool(forKey: type.rawValue)
//    }
//
//    func getInt(_ type: StorageType) -> Int {
//        UserDefaults.standard.integer(forKey: type.rawValue)
//    }
//
//    func save<T>(_ type: StorageType, value: T) {
//        UserDefaults.standard.set(value, forKey: type.rawValue)
//    }
//}
