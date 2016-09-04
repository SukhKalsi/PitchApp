//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Sukh on 10/06/2015.
//  Copyright (c) 2015 Sukh Kalsi. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController, AVAudioPlayerDelegate {
    
    var audioPlayer:AVAudioPlayer!
    var audioPlayer2:AVAudioPlayer!
    var audioEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var receivedAudio:RecordedAudio!
    var audioPlayerCount:Int = 0
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBAction func stopAudio(sender: UIButton) {
        // call generic reset and hide the stop button
        resetAudio()
        stopButton.hidden = true
    }
    
    @IBAction func playSlow(sender: UIButton) {
        // call generic reset and call play audio at half the rate. Show stop button
        resetAudio()
        playAudio(0.5)
        stopButton.hidden = false
    }

    @IBAction func playFast(sender: UIButton) {
        // call generic reset and call play audio at faster rate, at one and half speed. Show stop button
        resetAudio()
        playAudio(1.5)
        stopButton.hidden = false
    }
    
    @IBAction func playChipmunkAudio(sender: UIButton) {
        // call generic reset and call generic pitched audio at pitch value at higher pitch. Show stop button
        resetAudio()
        playAudioWithVariablePitch(1000)
        stopButton.hidden = false
    }
    
    @IBAction func playDarthvaderAudio(sender: UIButton) {
        // call generic reset and call generic pitched audio at pitch value at deeper pitch. Show stop button
        resetAudio()
        playAudioWithVariablePitch(-1000)
        stopButton.hidden = false
    }
    
    @IBAction func playEchoAudio(sender: UIButton) {
        // call generic reset and call echo function. Show stop button
        resetAudio()
        playAudioWithEcho(1.0, delay: 1.2, volume: 0.6)
        stopButton.hidden = false
    }
    
    func resetAudio() {
        // reset player count and stop / reset audio players and audio engines
        audioPlayerCount = 0
        audioPlayer.stop()
        audioPlayer2.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAudio(rate: Float) {
        // play the audio at the rate passed through. Also set the play time to zero, and increase the audio player count
        audioPlayer.currentTime = 0.0;
        audioPlayer.rate = rate
        audioPlayer.play()
        audioPlayerCount++;
    }
    
    func playAudioWithEcho(rate: Float, delay: NSTimeInterval, volume: Float) {
        // call play audio as normal
        playAudio(rate)
        
        // increment for echo straight away
        audioPlayerCount++;
        
        // now setup a delay for the 2nd sound so it simulates an echo
        var playtime:NSTimeInterval
        playtime = audioPlayer2.deviceCurrentTime + delay
        
        // play the 2nd audio after the delay (using playAtTime)
        audioPlayer2.currentTime = 0.0
        audioPlayer2.volume = volume;
        audioPlayer2.playAtTime(playtime)
    }
    
    func playAudioWithVariablePitch(pitch: Float) {
        // Initiate Audio Player Node and attach this to our Audio Engine
        var audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        // Initiate Audio Time Pitch and set the pitch value to parameter value passed through. Attach this to the Audio Engine.
        var changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch
        audioEngine.attachNode(changePitchEffect)
        
        // within the Audio Engine, connect the Player Node to the Pitch Effect. Finally attach the Pitch Effect to the Output Node.
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        // Schedule the file to play immediately, with a completion handler to hide the stop button.
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: {
            /**
                iOS 8 Bug
                
                Documentation states: "Called after the buffer has completely played or the player is stopped. May be nil."

                For some reason this completion handler is called immediately.
                In addition there appears to be a delay (about 2 seconds) somewhere when hiding the button
            */
            self.stopButton.hidden = true
        })
        
        // Play the audio
        audioEngine.startAndReturnError(nil)
        audioPlayerNode.play()
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        // Delegate provided by AVAudioPlayerDelegate. This detects when the AV Audio Player instance has finished playing the file.
        // Decrease the player counter and cross check we come to last file (due to echo having multiple instances). If so, hide the stop button.
        --audioPlayerCount;
        if (audioPlayerCount == 0) {
            stopButton.hidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Main audio
        audioPlayer = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer.enableRate = true
        audioPlayer.delegate = self
        
        // Echoed Audio
        audioPlayer2 = AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl, error: nil)
        audioPlayer2.enableRate = true
        audioPlayer2.delegate = self
        
        // Engine for pitching
        audioEngine = AVAudioEngine()
        
        audioFile = AVAudioFile(forReading: receivedAudio.filePathUrl, error: nil)
        
        // hide the stop button as its redundant unless we playing audio
        stopButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
