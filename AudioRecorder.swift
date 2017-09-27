
//
//  AudioRecorder.swift
//  VoiceRecognitionFromFile
//
//  Created by Julian Scharf on 27/9/17.
//  Copyright © 2017 Julian Scharf. All rights reserved.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var recordingIsPaused: Bool = false
    
    func recordAudio() {
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
        } else {
            audioRecorder.record()
            recordingIsPaused = false
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag) {
            recordedAudio = RecordedAudio(audioFilePathURL: recorder.url as NSURL, audioTitle: recorder.url.lastPathComponent)
            print(recordedAudio.filePathURL)
            print("recording was successful")
            
        } else {
            print("Recording was not successful")
        }
    }
    
    
    func pauseRecording() {
        audioRecorder.pause()
        recordingIsPaused = true
    }
    
    func stopRecording() {
        audioRecorder.stop()
        audioRecorderDidFinishRecording(audioRecorder, successfully: true)
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func getRecording() -> RecordedAudio? {
        if recordedAudio != nil {
            return recordedAudio
        }
        return nil
    }
    
}
