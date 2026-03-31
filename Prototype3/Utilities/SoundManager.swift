//
//  SoundManager.swift
//  Prototype3
//
//  Created by Andrea Ferrarini on 24/12/21.
//

/*
 * -- Main audio management module --
 * Holds the SoundManager class: each instance of it is an audio-player waiting to be played
 *
 * Attrib: audioPlayer
 * init()
 * Method: playSound()
 */


import Foundation
import AVFoundation


class SoundManager {

    // Audio player attribute
    var audioPlayer: AVAudioPlayer?

    // MARK: following initializer will fetch the correct audio file and prepare it to be played
    init() {
        // Fetching audio file
        guard let audioFile = Bundle.main.url(forResource: "ding", withExtension: "mp3") else { return }
        
        // Trying to prepare the audio player
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
            
            // Adjusting audioPlayer's parameters
            audioPlayer?.volume = 0.10
            audioPlayer?.prepareToPlay()
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        
        } catch {
            print("--- Error in audioPlayer preparation ---")
        }
    }

    func playSound() {
        // Actually playing the popping notification sound
        guard let player = audioPlayer else { return }
        player.play()
    }
}
