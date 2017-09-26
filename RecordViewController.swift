//
//  RecordViewController.swift
//  VoiceRecognitionFromFile
//
//  Created by Julian Scharf on 25/9/17.
//  Copyright © 2017 Julian Scharf. All rights reserved.
//

import UIKit

class RecordViewController: UIViewController {
    
    var apiMockTimer: Timer!
    
    @IBOutlet weak var microphoneView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var eqVisualiserView: UIImageView!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var transcribeButton: UIButton!
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI(state: .inactiveNoPayload)
    }
    
    func updateUI(state: State) {
        switch state {
        case .inactiveNoPayload:
            recordLabel.text = "inactiveNoPayload"
            playButton.isEnabled = false
            transcribeButton.isEnabled = false
            recordButton.setTitle("Record", for: .normal)
            resetClock(label: clockLabel)
        case .recording:
            recordLabel.text = "recording"
            playButton.isEnabled = false
            recordButton.isEnabled = true
            transcribeButton.isEnabled = false
            startClock(label: clockLabel)
        case .transcribingAudio:
            recordLabel.text = "transcribingAudio"
            playButton.isEnabled = false
            instructionsLabel.text = "audio is being transcribed"
            transcribeButton.isEnabled = false
            recordLabel.isEnabled = false
            recordButton.isEnabled = false
        case .playingRecording:
            recordLabel.text = "playingRecording"
            instructionsLabel.text = "playing recording"
            startClock(label: clockLabel)
        case .inactiveWithPayload:
            recordLabel.text = "inactiveWithPayload"
            instructionsLabel.text = "Press rec to continue recording\nPress Transcribe to transcribe audio"
            transcribeButton.isEnabled = true
            pauseClock(label: clockLabel)
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
        pauseClock(label: clockLabel)
        callApi()
    }
    
    @IBAction func playRecording(_ sender: Any) {
        updateUI(state: .playingRecording)
        startClock(label: clockLabel)
    }
    
    @objc func startRecording() {
        updateUI(state: .recording)
    }
    
    @objc func pauseRecording() {
        updateUI(state: .inactiveWithPayload)
    }
    
    func startClock(label: UILabel) {
        label.text = "clock started"
    }
    
    func pauseClock(label: UILabel) {
        label.text = "clock paused"
    }
    
    func resetClock(label: UILabel) {
        label.text = "00:00:00"
    }
    
    func  callApi() {
        apiMockTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(transriptionComplete), userInfo: nil, repeats: false)
    }
    
    @objc func transriptionComplete() {
        updateUI(state: .audioHasBeenTranscribed)
        
    }
    
}
