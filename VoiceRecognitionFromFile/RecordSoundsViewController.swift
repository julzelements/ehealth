//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Julian Scharf on 16/02/2016.
//  Copyright © 2016 Julian Scharf. All rights reserved.
//

import UIKit
import AVFoundation


class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var displayResults: UILabel!
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var recordingIsPaused: Bool = false
    var testString: String!
    
    enum DisplayState {
        case notRecording
        case recording
        case paused
    }
    
    func updateDisplay(displayState: DisplayState) {
        switch displayState {
        case .notRecording:
            recordingInProgress.isHidden = false
            recordingInProgress.text = "Tap to Record"
            stopButton.isHidden = true
            pauseButton.isHidden = true
        case .recording:
            recordingInProgress.text = "Recording in Progress..."
            pauseButton.isHidden = false
            stopButton.isHidden = false
        case .paused:
            recordingInProgress.text = "Paused \n Tap to Resume Recording"
            pauseButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateDisplay(displayState: .notRecording)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBAction func recordAudio(sender: UIButton) {
        if recordingIsPaused == false {
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let recordingName = "my_audio.wav"
            let pathArray = [dirPath, recordingName]
            let filePath = NSURL.fileURL(withPathComponents: pathArray)
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            updateDisplay(displayState: .recording)
        } else {
            audioRecorder.record()
            recordingIsPaused = false
            updateDisplay(displayState: .recording)
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag) {
            recordedAudio = RecordedAudio(audioFilePathURL: recorder.url as NSURL, audioTitle: recorder.url.lastPathComponent)
                print(recordedAudio.filePathURL)
                print("recording was successful")
            performSegue(withIdentifier: "showNotes", sender: nil)            
        } else {
            print("Recording was not successful")
        }
    }
    
    
    @IBAction func pauseRecording(sender: UIButton) {
        audioRecorder.pause()
        updateDisplay(displayState: .paused)
        recordingIsPaused = true
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        recordingInProgress.isHidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        let destinationViewController = segue.destination as! ViewNoteViewController
        if let recording = self.recordedAudio {
            destinationViewController.recordedAudio = recording
        }
    }
    
}
