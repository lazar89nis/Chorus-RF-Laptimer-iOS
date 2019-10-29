//
//  RacePilotTVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/27/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import FZAccordionTableView

class RacePilotTVC: FZAccordionTableViewHeaderView {
    
    @IBOutlet weak var colorRibon: UIView!
    @IBOutlet weak var pilotLabel: UILabel! // Pilot 1 (C 1, E band) Laps: 4 FINISHED
    @IBOutlet weak var positionLabel: UILabel! // Position:     1    Race Time: 0:00.000
    @IBOutlet weak var lastLapLabel: UILabel! // Last Lap:     0:03.889
    @IBOutlet weak var bestLapLabel: UILabel! // Best Lap:    0:03.889     Best lap position: 1
    
    @IBOutlet weak var bestLapPositionLabel: UILabel!
    @IBOutlet weak var raceTimeLabel: UILabel!
    @IBOutlet weak var raceStatusLabel: UILabel!
    @IBOutlet weak var lapNumberLabel: UILabel!
    
    func setupCell(deviceNumber: Int, pilot: CRFPilot)
    {
        colorRibon.backgroundColor = Constants.pilotColor[UserDefaults.standard.integer(forKey: "\(UserDefaultsId.pilotColorIndex)\(pilot.pilotID)")]

        var lapCount = pilot.laps.count
        if CRFData.shared.skipFirstLap
        {
            lapCount -= 1
        }
        
        if lapCount < 0
        {
            lapCount = 0
        }
        
        if lapCount >= CRFData.shared.lapsToGo && lapCount>0
        {
            raceStatusLabel.text = "FINISHED"
        } else {
            raceStatusLabel.text = ""
        }
        
        pilotLabel.text = "\(pilot.getPilotName()) (Channel: \(pilot.channelId+1), Band: \(Constants.frequencies[pilot.bandId].band))"
        lapNumberLabel.text = "\(lapCount)"
        
        positionLabel.text = "\(pilot.getCurrentPosition())"
        
        raceTimeLabel.text = "\(pilot.formatRaceTime(milisecounds: pilot.getRaceTime()))"
        
        if pilot.laps.count > 0
        {
            lastLapLabel.text = "\(pilot.formatRaceTime(milisecounds: pilot.laps.last!.lapTime))"
        } else {
            lastLapLabel.text = ""
        }
        
        bestLapLabel.text = "\(pilot.formatRaceTime(milisecounds: pilot.getBestLapTime()))"
        bestLapPositionLabel.text = "\(pilot.getBestLapPosition())"
    }
}
