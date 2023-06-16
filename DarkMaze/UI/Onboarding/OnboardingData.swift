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
        OnboardingData(id: 1, primaryText: "Welcome to Dark Maze", secondaryText: "An immersive game for visually impaired individuals", lottie: "hello"),
        OnboardingData(id: 2, primaryText: "Explore complex Mazes", secondaryText: "Engage all your senses beyond vision for an inclusive experience", lottie: ""),
        OnboardingData(id: 3, primaryText: "Turn on sounds and haptic", secondaryText: "It's essential features for navigating through the Maze", lottie: "")
    ]
}
