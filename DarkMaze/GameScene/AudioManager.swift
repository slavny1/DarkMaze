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
        guard let url = Bundle.main.url(forResource: "ufo", withExtension: "mp3") else { return }

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
        audioPlayer.volume = volume
    }

    func stopAudio() {
        audioPlayer.stop()
    }

    func moveSound(volume: Float) {
        playAudio(named: "ufo")
        self.volume = volume
    }
}
