//
//  ViewNoteViewController
//  VoiceRecognitionFromFile
//
//  Created by Julian Scharf on 20/9/17.
//  Copyright © 2017 Julian Scharf. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewNoteViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var timeStampLabel: UILabel!
    var testString: String!
    var audioPlayer: AVAudioPlayer!
    var recordedAudio: RecordedAudio!
    var result: SFSpeechRecognitionResult!
    var audioEngine: AVAudioEngine!
    var audioFile: AVAudioFile!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    @IBOutlet var textView : UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("here is my audio")
        //        Sets the default device output to the loudspeaker (instead of the handset)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
        
        print(recordedAudio.filePathURL)
        print(testString)
        
        audioPlayer = try! AVAudioPlayer(contentsOf: recordedAudio.filePathURL as URL)
        audioEngine = AVAudioEngine()
        try! audioFile = AVAudioFile(forReading: recordedAudio.filePathURL as URL)
        
        timeStampLabel.text = getFormattedDate(date: recordedAudio.timeRecorded)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let audioURL = Bundle.main.url(forResource: "patientNotesRecording", withExtension: "wav")
//        recognizeFile(url: audioURL!)
        recognizeFile(url: recordedAudio.filePathURL as URL!)
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
                self.textView.attributedText = formattedText
                print(formattedText)
                print("recognition complete")
//                self.presentTextOnTextView(text: formattedText, textView: self.textView)
//                self.selectRangeInTextView(result: result, textView: self.textView)
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

                }
            }
        }
    @IBAction func playbackNote(_ sender: Any) {
        stopAll()
        playAtSpeed(speed: 1.0)
    }
    
    func stopAll() {
        audioPlayer.stop()
        audioEngine.stop()
        audioEngine.reset()
    }
    
    func playAtSpeed(speed: Float) {
        stopAll()
        audioPlayer.enableRate = true
        audioPlayer.rate = speed
        audioPlayer.play()
    }
    
    func getFormattedDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy, hh:mm:ss"
        
        return (dateFormatter.string(from: date))
    }
    
    }


