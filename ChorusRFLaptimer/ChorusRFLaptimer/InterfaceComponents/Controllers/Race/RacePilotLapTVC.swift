//
//  RacePilotLapTVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/27/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit

class RacePilotLapTVC: UITableViewCell {

    @IBOutlet weak var lapLabel: UILabel!
    @IBOutlet weak var lapTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setLapTime(lapNumber: Int, lapTime: UInt64, pilot: CRFPilot)
    {
        let bestLapPostion = pilot.getBestLapPostion()
        
        if bestLapPostion == lapNumber
        {
            lapLabel.textColor = UIColor.red
            lapTimeLabel.textColor = UIColor.red
        } else {
            lapLabel.textColor = UIColor.black
            lapTimeLabel.textColor = UIColor.black
        }
        
        var lapNumberVal = lapNumber
        if !CRFData.shared.skipFirstLap
        {
            lapNumberVal += 1
        }
        
        lapLabel.text = "Lap # \(lapNumberVal):"
        lapTimeLabel.text = "\(pilot.formatRaceTime(milisecounds: lapTime))"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
