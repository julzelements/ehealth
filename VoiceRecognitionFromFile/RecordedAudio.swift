//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Julian Scharf on 17/02/2016.
//  Copyright © 2016 Julian Scharf. All rights reserved.
//

import Foundation

class RecordedAudio {
  
  var filePathURL: NSURL!
  var title: String!
  
  init(audioFilePathURL: NSURL, audioTitle: String) {
    filePathURL = audioFilePathURL
    title = audioTitle
  }
  
}