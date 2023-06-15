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
    let image: String?

    static let list: [OnboardingData] = [
        OnboardingData(id: 1, primaryText: "Hello", secondaryText: "world!", image: ""),
        OnboardingData(id: 2, primaryText: "Hello", secondaryText: "world!", image: ""),
        OnboardingData(id: 3, primaryText: "Hello", secondaryText: "world!", image: "")
    ]
}
