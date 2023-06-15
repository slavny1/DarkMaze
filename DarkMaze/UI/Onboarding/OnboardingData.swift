//
//  OnboardingData.swift
//  DarkMaze
//
//  Created by Viacheslav on 15/06/23.
//

import Foundation

struct OnboardingData: Hashable, Identifiable {

    let id: Int
    let primaryText: String
    let secondaryText: String
    let lottie: String

    static let list: [OnboardingData] = [
        OnboardingData(id: 1, primaryText: "Welcome to Dark Maze", secondaryText: "extraordinary sensorial experience game", lottie: "hello"),
        OnboardingData(id: 2, primaryText: "Hello", secondaryText: "world!", lottie: ""),
        OnboardingData(id: 3, primaryText: "Hello", secondaryText: "world!", lottie: "")
    ]
}
