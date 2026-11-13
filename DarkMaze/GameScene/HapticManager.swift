//
//  HapticManager.swift
//  DarkMaze
//
//  Created by Viacheslav on 08/07/23.
//

import Foundation
import UIKit

final class HapticManager {
    static func ballTouched() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.warning)
    }

    static func ballMoving() {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
    }

    static func collisionOccurred() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.error)
    }

    static func ballWin() {
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
    }

    static func joystickCentered() {
        let feedback = UIImpactFeedbackGenerator(style: .soft)
        feedback.impactOccurred(intensity: 0.35)
    }

    static func wallProximity(intensity: CGFloat) {
        // Gentle at the outer range; a firmer pulse as collision nears.
        let feedback = UIImpactFeedbackGenerator(style: .rigid)
        feedback.impactOccurred(intensity: min(max(intensity, 0.12), 1))
    }

    static func joystickLocated() {
        // Distinct from the warning used for discovering the ball.
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }

    static func buttonTapped() {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
}
