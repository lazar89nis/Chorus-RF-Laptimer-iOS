//
//  CRFPilot.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 10/12/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import HCFramework

class CRFPilot: NSObject {

    var pilotID: Int = 0
    var RSSI: Int = 0
    var bandId: Int = 0
    var channelId: Int = 0
    var name: String = ""
    var threshold: Int = 0
    var isEnabled: Bool = true
    var calibrationTime1: Int32 = -1
    var calibrationTime2: Int32 = -1
    var calibrationStage: Int = 0
    
    var apiVersion: Int = 0
    
    var isDeviceConfigured: Bool = false
    
    var laps: [CRFLap] = []
    
    var RSSIS: [Double] = []
    
    init(pilotId: Int)
    {
        super.init()
        
        self.pilotID = pilotId
        
        if let pilotName = UserDefaults.standard.string(forKey: "Device\(pilotID)PilotName")
        {
            name = pilotName
        }
        
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(CRFPilot.storeRSSI), userInfo: nil, repeats: true)
    }
    
    func findMaxRSSI() -> Double
    {
        if RSSIS.count == 0
        {
            return 0.0
        }
        return RSSIS.max()!
    }
    
    @objc func storeRSSI()
    {
        if RSSIS.count == 300
        {
            RSSIS.remove(at: 0)
        }
        RSSIS.append(Double(RSSI))
        
        HCAppNotify.postNotification(NotificationCenterId.RSSISupdated, object: false as AnyObject?)
    }
    
    func getPilotName() -> String
    {
        if name == ""
        {
            return "Pilot\(pilotID+1)"
        }
        return name
    }
    
    func getRaceTime() -> UInt64
    {
        var totalTime: UInt64 = 0
        var i = 0
        for lap in laps
        {
            if (CRFData.shared.skipFirstLap && i==0) || i > CRFData.shared.lapsToGo
            {
                //print("skip")
            } else {
                totalTime += lap.lapTime
            }
            i += 1
        }
        
        return totalTime
    }
    
    func getBestLapTime() -> UInt64
    {
        var min = UInt64.max
        var i = 0
        for lap in laps
        {
            if lap.lapTime < min {
                if (CRFData.shared.skipFirstLap && i==0) || i > CRFData.shared.lapsToGo
                {
                    //print("skip")
                } else {
                    min = lap.lapTime
                }
            }
            i += 1
        }
        
        return min
    }
    
    func getBestLapPostion() -> Int
    {
        var bestPostion = 0
        var min = UInt64.max
        var i = 0
        for lap in laps
        {
            if lap.lapTime < min{
                if (CRFData.shared.skipFirstLap && i==0) || i > CRFData.shared.lapsToGo
                {
                    //print("skip")
                } else {
                    min = lap.lapTime
                    bestPostion = i
                }
            }
            i += 1
        }
        
        return bestPostion
    }
    
    func formatRaceTime(milisecounds: UInt64) -> String
    {
        let date = Date(timeIntervalSince1970: Double(milisecounds) / 1000)
        let formatter = DateFormatter()
        formatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        formatter.dateFormat = "m:ss.SSS"
        let raceTime = formatter.string(from: date)
        
        return raceTime
    }
    
    func getCurrentPosition() -> Int
    {        
        var otherPilotTimes: [UInt64] = []
        var numberOfLapsDone: [Int] = []
        
        for pilot in CRFData.shared.pilots
        {
            if pilot.pilotID == pilotID
            {
                continue
            }
            
            otherPilotTimes.append(pilot.getRaceTime())
            numberOfLapsDone.append(pilot.laps.count)
        }
        
        var position = 1
        
        let myTotalTime = getRaceTime()
        
        for i in 0 ..< CRFData.shared.numberOfDevices - 1
        {
            if laps.count < numberOfLapsDone[i]  || (myTotalTime > otherPilotTimes[i] && numberOfLapsDone[i] >= laps.count)
            {
                position += 1
            }
        }
        
        return position
    }
    
    func getBestLapPosition() -> Int
    {
        if laps.count == 0
        {
            return 0
        }
        
        let bestLapId = getBestLapPostion()
        let bestLaptime = getBestLapTime()
        
        var otherPilotTime: [UInt64] = []
        
        for pilot in CRFData.shared.pilots
        {
            if pilot.pilotID == pilotID
            {
                continue
            }
            
            if pilot.laps.count < bestLapId+1
            {
                otherPilotTime.append(UInt64.max)
            } else {
                otherPilotTime.append(pilot.laps[bestLapId].lapTime)
            }
        }
        
        var position = 1
        
        for i in 0 ..< CRFData.shared.numberOfDevices - 1 {
            if bestLaptime > otherPilotTime[i]
            {
                position += 1
            }
        }
        
        return position
    }
}
