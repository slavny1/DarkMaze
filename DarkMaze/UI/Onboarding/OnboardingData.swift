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
//    let lottie: String

    static let list: [OnboardingData] = [
        OnboardingData(id: 0, primaryText: "Welcome to Dark Maze", secondaryText: "An immersive game for visually impaired individuals"),
        OnboardingData(id: 1, primaryText: "Explore complex Mazes", secondaryText: "Engage all your senses beyond vision"),
        OnboardingData(id: 2, primaryText: "Turn on sounds and haptic", secondaryText: "It's essential features for navigating through the Maze")
    ]
}
