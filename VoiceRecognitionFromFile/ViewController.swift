//
//  ViewController.swift
//  VoiceRecognitionFromFile
//
//  Created by Julian Scharf on 20/9/17.
//  Copyright © 2017 Julian Scharf. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    var audioURL: URL!
    var result: SFSpeechRecognitionResult!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    @IBOutlet var textView : UITextView!
    
    @IBOutlet var recordButton : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioURL = Bundle.main.url(forResource: "patientNotesRecording", withExtension: "wav")
        recognizeFile(url: audioURL)
    }

    
    func recognizeFile(url: URL) {
        print(url)
        guard let recognizer = SFSpeechRecognizer() else {
            //not suppoorted
            return
        }
        if !recognizer.isAvailable {
            print("speech recognition not available right now")
            return
        }
        let request = SFSpeechURLRecognitionRequest(url: url)
        recognizer.recognitionTask(with: request) { (result, error) in
            guard let result = result
                else {
                    print("recognition failed")
                    return
            }
            if result.isFinal {
                self.result = result
                let formattedText = self.formatResult(result: result)
                self.presentTextOnTextView(text: formattedText, textView: self.textView)
                self.selectRangeInTextView(result: result, textView: self.textView)
            }
        }
    }
    
    func selectRangeInTextView(result: SFSpeechRecognitionResult, textView: UITextView) {
        let uncertainRanges = getUncertainRanges(segments: result.bestTranscription.segments, confidenceCutoff: 0.5)
        if !uncertainRanges.isEmpty {
            textView.selectedRange = uncertainRanges[0]
        }
    }
    
    func presentTextOnTextView(text: NSMutableAttributedString, textView: UITextView) {
        textView.attributedText = text
    }

    func formatResult(result: SFSpeechRecognitionResult) -> NSMutableAttributedString {
        let bestTranscription = result.bestTranscription
        let string = bestTranscription.formattedString
        let segments = bestTranscription.segments
        let uncertainRanges = getUncertainRanges(segments: segments, confidenceCutoff: 0.5)
        let colouredText = makeTextRed(text: string, ranges: uncertainRanges)
        return colouredText
    }
    
    func getUncertainRanges(segments: [SFTranscriptionSegment], confidenceCutoff: Double) -> [NSRange] {
        var ranges = [NSRange]()
        for segment in segments {
            if segment.confidence < 0.5 {
                ranges.append(segment.substringRange)
            }
        }
        return ranges
    }

    func makeTextRed(text: String, ranges: [NSRange]) -> NSMutableAttributedString {
        let string:NSMutableAttributedString = NSMutableAttributedString(string: text)
        for range in ranges {
            string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: range)
        }
        return string
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
}

