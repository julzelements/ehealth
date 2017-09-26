//
//  StopWatch.swift
//  VoiceRecognitionFromFile
//
//  Created by Julian Scharf on 26/9/17.
//  Copyright © 2017 Julian Scharf. All rights reserved.
//

import Foundation
import UIKit

class StopWatch {
    
    init(label: UILabel) {
        timerLabel = label
        timerLabel.text = "00:00:00"
    }
    var isRecording: Bool = false
    let timerInterval = 0.01
    var timerLabel : UILabel!
    
    
    weak var timer: Timer?
    var startTime: Double = 0
    var time: Double = 0
    var elapsed: Double = 0

    @objc func startRecording() {
        isRecording = true
        print("Start Recording")
        startTime = Date().timeIntervalSinceReferenceDate - elapsed
        timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(updateTimerLabel), userInfo: nil, repeats: true)
    }
    
    @objc func stopRecording() {
        isRecording = false
        print("Stop Recording")
        elapsed = Date().timeIntervalSinceReferenceDate - startTime
        timer?.invalidate()
        timer = nil
    }
    
    
    @objc func updateTimerLabel(_ timer: Timer) {
        
        time = Date().timeIntervalSinceReferenceDate - startTime
        
        
        
        // Calculate minutes
        
        let minutes = UInt8(time / 60.0)
        
        time -= (TimeInterval(minutes) * 60)
        
        
        
        // Calculate seconds
        
        let seconds = UInt8(time)
        
        time -= TimeInterval(seconds)
        
        
        
        // Calculate millisecond
        
        let milliseconds = UInt8(time * 100)
        
        
        
        let strFormattedTime = String(format: "%02d:%02d:%02d", minutes, seconds, milliseconds)
        
        
        
        timerLabel.text = strFormattedTime
        
    }
    
    
    
    func resetTimer() {
        startTime = 0
        time = 0
        elapsed = 0
    }
    
}
