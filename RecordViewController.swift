//
//  RecordViewController.swift
//  VoiceRecognitionFromFile
//
//  Created by Julian Scharf on 25/9/17.
//  Copyright © 2017 Julian Scharf. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder:AVAudioRecorder!
    var apiMockTimer: Timer!
    var stopWatch: StopWatch!
    var recordingIsPaused: Bool = false
    var recordedAudio:RecordedAudio!
    
    @IBOutlet weak var microphoneView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var eqVisualiserView: UIImageView!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!

    enum State {
        case recording
        case inactiveNoPayload
        case inactiveWithPayload
        case transcribingAudio
        case paused
        case recognitionCompleted
        case playingRecording
        case audioHasBeenTranscribed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        recordButton.addTarget(self, action: #selector(startRecording), for: .touchDown)
        recordButton.addTarget(self, action: #selector(pauseRecording), for: .touchUpInside)
        recordButton.addTarget(self, action: #selector(pauseRecording), for: .touchUpOutside)
        stopWatch = StopWatch(label: clockLabel)
        recordingIsPaused = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI(state: .inactiveNoPayload)
    }
    
    func updateUI(state: State) {
        switch state {
        case .inactiveNoPayload:
            recordLabel.text = "inactiveNoPayload"
            playButton.isEnabled = false
            stopButton.isEnabled = false
            recordButton.setTitle("Record", for: .normal)
            stopWatch.resetTimer()
        case .recording:
            recordLabel.text = "recording"
            playButton.isEnabled = false
            recordButton.isEnabled = true
            recordButton.setTitle("pause", for: .normal)
            stopButton.isEnabled = false
            stopWatch.startRecording()
        case .transcribingAudio:
            recordLabel.text = "transcribingAudio"
            playButton.isEnabled = false
            instructionsLabel.text = "audio is being transcribed"
            stopButton.isEnabled = false
            recordLabel.isEnabled = false
            recordButton.isEnabled = false
        case .playingRecording:
            recordLabel.text = "playingRecording"
            instructionsLabel.text = "playing recording"
            stopWatch.resetTimer()
            stopWatch.startRecording()
        case .inactiveWithPayload:
            recordLabel.text = "inactiveWithPayload"
            instructionsLabel.text = "Press rec to continue recording\nPress Transcribe to transcribe audio"
            stopButton.isEnabled = true
            stopWatch.stopRecording()
        case .audioHasBeenTranscribed:
            recordLabel.text = "inactiveWithPayload"
            instructionsLabel.text = "Audio has been transcribed"
            playButton.isEnabled = true
            
        default:
            return
        }
    }
    
    @IBAction func transcribeRecording(_ sender: Any) {
        updateUI(state: .transcribingAudio)
        callApi()
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    @IBAction func playRecording(_ sender: Any) {
        updateUI(state: .playingRecording)
    }

    @objc func startRecording() {
        updateUI(state: .recording)
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
            updateUI(state: .recording)
        } else {
            audioRecorder.record()
            recordingIsPaused = false
            updateUI(state: .recording)
        }
    }
    
    @objc func pauseRecording() {
        audioRecorder.pause()
        updateUI(state: .inactiveWithPayload)
        recordingIsPaused = true
    }
    
    func  callApi() {
        apiMockTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(transriptionComplete), userInfo: nil, repeats: false)
    }

    @objc func transriptionComplete() {
        updateUI(state: .audioHasBeenTranscribed)
        
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
    
}
