//
//  CRFData.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 10/12/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit

class CRFData: NSObject {
    
    var numberOfDevices: Int = 0
    
    var pilots: [CRFPilot] = []
    var pilotsInRace: [CRFPilot] = []

    var raceIsOn : Bool = false
    
    var lapsToGo: Int = 0
    var timeToPrepareForRace: Int = 0
    var speakLapTimes: Bool = false
    var speakMessages: Bool = false
    
    var skipFirstLap: Bool = false
    var minLapTime: Int = 1
    var deviceSoundEnabled: Bool = false
    var voltage: Int = 0
    var voltageMonitorOn: Bool = false
    var voltageAdjustment: Int = 0
    
    var setupInProgress: Bool = false
    
    static let shared: CRFData = {
        let instance = CRFData()
        
        instance.timeToPrepareForRace = UserDefaults.standard.integer(forKey: UserDefaultsId.timeToPrepareForRace)
        instance.lapsToGo = UserDefaults.standard.integer(forKey: UserDefaultsId.lapsToGo)

        instance.speakMessages = UserDefaults.standard.bool(forKey: UserDefaultsId.speakMessages)
        instance.speakLapTimes = UserDefaults.standard.bool(forKey: UserDefaultsId.speakLapTimes)
        
        instance.voltageAdjustment = UserDefaults.standard.integer(forKey: UserDefaultsId.voltageAdjustment)
        instance.voltageMonitorOn = UserDefaults.standard.bool(forKey: UserDefaultsId.voltageMonitorOn)
        
        return instance
    }()
    
    func checkIfThereIsRaceResaults() -> Bool
    {
        for pilot in pilots
        {
            if pilot.laps.count > 0
            {
                return true
            }
        }
        return false
    }
    
    func resetPilots(_ numberOfPilots:Int)
    {
        numberOfDevices = numberOfPilots
        
        pilots.removeAll()
        pilotsInRace.removeAll()
        for i in 0 ..< numberOfDevices {
            pilots.append(CRFPilot(pilotId: i))
        }
        
        setupInProgress = true
        CRFSendCommandManager.shared.sendMessage("R*"+Command.bulkDeviceState)
        CRFSendCommandManager.shared.sendMessage("R*"+Command.liPoVoltage)
    }
    
    func resetPilotTimes()
    {
        for i in 0 ..< numberOfDevices {
            pilots[i].laps.removeAll()
        }
    }
}
