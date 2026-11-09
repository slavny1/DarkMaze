//
//  AudioManager.swift
//  DarkMaze
//
//  Created by Viacheslav on 08/07/23.
//

import Foundation
import AVFoundation

final class AudioManager {

    private var audioPlayer = AVAudioPlayer()
    private var volume: Float = 0

    private func playAudio(named fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else { return }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.enableRate = true
            audioPlayer.numberOfLoops = -1
            audioPlayer.volume = volume
            audioPlayer.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func updateVolume(volume: Float) {
        self.volume = min(max(volume, 0), 1)
        audioPlayer.volume = self.volume
    }

    func stopAudio() {
        audioPlayer.stop()
    }

    func moveSound(volume: Float) {
        self.volume = min(max(volume, 0), 1)
        playAudio(named: "ufo")
    }

    func playStepCue(volume: Float) {
        // For VoiceOver nudges, play a non-looping tone whose loudness reflects
        // the actual distance to walls (rather than narrating the maze).
        stopAudio()
        self.volume = min(max(volume, 0), 1)
        guard let url = Bundle.main.url(forResource: "ufo", withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        audioPlayer = player
        audioPlayer.numberOfLoops = 0
        audioPlayer.volume = self.volume
        audioPlayer.play()
    }
}


// MARK: - Discovering controls by touch

enum DiscoveryTarget: Equatable {
    case ball
    case joystick

    var playbackRate: Float {
        // Both targets use the familiar ball-found sound. A different
        // pitch distinguishes the joystick without requiring another asset.
        switch self {
        case .ball: return 1.0
        case .joystick: return 1.3
        }
    }
}

final class DiscoveryAudioManager {
    private var scanningPlayer: AVAudioPlayer?
    private var confirmationPlayer: AVAudioPlayer?
    private var currentTarget: DiscoveryTarget?

    func update(target: DiscoveryTarget?, proximity: CGFloat) {
        guard let target, proximity > 0.02 else {
            stopScanning()
            return
        }
        if currentTarget != target || scanningPlayer == nil {
            stopScanning()
            guard let audioURL = Bundle.main.url(forResource: "bonus", withExtension: "mp3"),
                  let player = try? AVAudioPlayer(contentsOf: audioURL) else { return }
            scanningPlayer = player
            player.enableRate = true
            player.rate = target.playbackRate
            player.numberOfLoops = -1
            player.volume = 0.01
            player.play()
            currentTarget = target
        }

        // Quiet at the outer discovery range, louder on approach.
        let closeness = Float(min(max(proximity, 0), 1))
        scanningPlayer?.volume = 0.012 + closeness * closeness * 0.45
    }

    func confirm(_ target: DiscoveryTarget) {
        guard let audioURL = Bundle.main.url(forResource: "bonus", withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: audioURL) else { return }
        confirmationPlayer?.stop()
        confirmationPlayer = player
        player.enableRate = true
        player.rate = target.playbackRate
        player.numberOfLoops = 0
        player.volume = 0.85
        player.play()
    }

    func stopScanning() {
        scanningPlayer?.stop()
        scanningPlayer = nil
        currentTarget = nil
    }

    func stop() {
        stopScanning()
        confirmationPlayer?.stop()
        confirmationPlayer = nil
    }
}
