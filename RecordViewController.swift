//
//  RecordViewController.swift
//  VoiceRecognitionFromFile
//
//  Created by Julian Scharf on 25/9/17.
//  Copyright © 2017 Julian Scharf. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit
import AudioKitUI

class RecordViewController: UIViewController{
    
    var apiMockTimer: Timer!
    var stopWatch: StopWatch!
    var recordingIsPaused: Bool = false
    var audioRecorder: AudioRecorder!
    var recordedAudio:RecordedAudio!
    var tracker : AKFrequencyTracker!
    let mic = AKMicrophone()
    
    @IBOutlet weak var microphoneView: UIView!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var eqVisualiserView: UIImageView!
    @IBOutlet weak var clockLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var audioInputPlot: UIView!
    
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
        audioRecorder = AudioRecorder()
        
        AKAudioFile.cleanTempDirectory()
        AKSettings.bufferLength = .medium
        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .rolling
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        print(plot)
        audioInputPlot.addSubview(plot)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI(state: .inactiveNoPayload)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tracker = AKFrequencyTracker.init(mic, hopSize: 128, peakCount: 64)
        AudioKit.output = AKBooster(tracker, gain: 0)
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
            tracker.start()
            AudioKit.start()
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
            tracker.stop()
            AudioKit.stop()
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
        audioRecorder.stopRecording()
        recordedAudio = audioRecorder.getRecording()
        print(recordedAudio)
        callApi()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        performSegue(withIdentifier: "doTranscription", sender: nil)
    }
    
    @IBAction func playRecording(_ sender: Any) {
        updateUI(state: .playingRecording)
    }

    @objc func startRecording() {
        updateUI(state: .recording)
        audioRecorder.recordAudio()
    }
    
    @objc func pauseRecording() {
        updateUI(state: .inactiveWithPayload)
        recordingIsPaused = true
        audioRecorder.pauseRecording()
    }
    
    func  callApi() {
        apiMockTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(transriptionComplete), userInfo: nil, repeats: false)
    }

    @objc func transriptionComplete() {
        updateUI(state: .audioHasBeenTranscribed)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! ViewNoteViewController
        if let recording = self.recordedAudio {
            destinationViewController.recordedAudio = recording
        }
    }

}
