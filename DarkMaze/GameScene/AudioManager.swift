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

    func playStepCue() {
        // A brief instance of the existing movement tone. Repeated taps
        // should not create multiple looping players.
        stopAudio()
        self.volume = 0.35
        guard let url = Bundle.main.url(forResource: "ufo", withExtension: "mp3"),
              let player = try? AVAudioPlayer(contentsOf: url) else { return }
        audioPlayer = player
        audioPlayer.numberOfLoops = 0
        audioPlayer.volume = volume
        audioPlayer.play()
    }
}
