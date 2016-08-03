//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Sukh on 08/06/2015.
//  Copyright (c) 2015 Sukh Kalsi. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var introText: UILabel!
    
    @IBAction func recordAudio(sender: UIButton) {
        // show and hide UI elements
        introText.hidden = true
        recordingInProgress.hidden = false
        stopButton.hidden = false
        recordButton.enabled = false
        
        // setup file to save recording to
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        // setup session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // assign properties and begin recording - N.B. delegate for record is set here too.
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        // show relevant UI elements
        recordingInProgress.hidden = true
        recordButton.enabled = true
        stopButton.hidden = true
        
        // stop the recording instance
        audioRecorder.stop()
        
        // end session
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        // detect is we finished recording successfully and if so create Recording Audio object to contain the relevant recording information
        // initiate a segue so we can transision to the playback screen
        if (flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            println("Recording was not successful.")
            recordButton.enabled = true
            stopButton.hidden = true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // identify valid segues
        if (segue.identifier == "stopRecording") {
            // assign destination View Controller property to object passed through to this segue - its so we know what to playback on the other View Controller
            let data = sender as! RecordedAudio
            let playSoundVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            playSoundVC.receivedAudio = data
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        // show and hide UI elements
        stopButton.hidden = true
        recordButton.enabled = true
        introText.hidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
