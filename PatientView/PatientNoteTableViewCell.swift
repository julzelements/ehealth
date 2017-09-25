//
//  PatientNoteTableViewCell.swift
//  VoiceRecognitionFromFile
//
//  Created by Julian Scharf on 25/9/17.
//  Copyright © 2017 Julian Scharf. All rights reserved.
//

import UIKit

class PatientNoteTableViewCell: UITableViewCell {

    @IBOutlet weak var drName: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func editNote(_ sender: Any) {
        print("note edited")
    }
    
    @IBAction func playNote(_ sender: Any) {
        print("note played")
    }
}
