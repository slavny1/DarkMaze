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
        OnboardingData(id: 0, primaryText: "Welcome to Dark Maze", secondaryText: "An immersive game for visually impaired individuals", lottie: "hello"),
        OnboardingData(id: 1, primaryText: "Explore complex Mazes", secondaryText: "Engage your senses beyond vision", lottie: ""),
        OnboardingData(id: 2, primaryText: "Turn on sounds", secondaryText: "It's essential for navigating in the maze", lottie: "")
    ]
}
