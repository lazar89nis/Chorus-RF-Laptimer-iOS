//
//  MessageParser.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 10/13/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import LDMainFramework

class CRFMessageParser: NSObject {
    
    static var btMessage: String = ""
    
    static func parsMessage(_ message: String)
    {
        if Constants.printMessageLogs
        {
            print("message")
            print(message)
        }
        
        if message.count >= 2
        {
            let lastTwoChars = message.ldSubstring(from: message.count-1 , to:message.count)
            if lastTwoChars == "\n"
            {
                CRFMessageParser.btMessage+=message
            } else if lastTwoChars == "\r\n"
            {
                CRFMessageParser.btMessage+=message
            } else  {
                CRFMessageParser.btMessage+=message
                return
            }
        }
        
        if Constants.printMessageLogs
        {
            //print(MessageParser.btMessage) //show message
        }
        
        let commands = CRFMessageParser.btMessage.components(separatedBy: "\n")
        
        for command in commands
        {
            if Constants.printMessageLogs
            {
                //print(command)
            }
            if command.count >= 2
            {
                let firstChar = command.ldSubstring(to: 0)
                
                if firstChar == "N" //device number
                {
                    if let deviceId = Int(command.ldSubstring(from: 1 , to:1)) {
                        CRFData.shared.resetPilots(deviceId)
                    }
                } else if firstChar == "S"
                {
                    if let deviceId = Int(command.ldSubstring(from: 1 , to:1))
                    {
                        let thirdChar = command.ldSubstring(from: 2 , to:2)
                        switch thirdChar {
                            
                        case "r": //MARK: <r> RSSI ***RSSI***
                            var valueStr = command.ldSubstring(from: 3 , to:7)
                            valueStr = String(valueStr.filter { !" \n".contains($0) })
                            if let value = UInt64(valueStr, radix: 16)
                            {
                                if CRFData.shared.pilots.count > deviceId
                                {
                                    CRFData.shared.pilots[deviceId].RSSI = Int(value)
                                    LDAppNotify.postNotification(NotificationCenterId.RSSIchanged, object: nil as AnyObject?)
                                }
                                
                                if deviceId == 0
                                {
                                    LDAppNotify.postNotification(NotificationCenterId.RSSIchangedSpectrum, object: Int(value) as AnyObject?)
                                }
                            }
                            
                        case "L": //MARK: <L> lap time ***Lap time***
                            let lapNumber = command.ldSubstring(from: 3 , to:4)
                            let lapTime = command.ldSubstring(from: 5 , to:12)
                            
                            if let lapNumberValue = UInt64(lapNumber, radix: 16)
                            {
                                if let lapTimeValue = UInt64(lapTime, radix: 16)
                                {
                                    CRFData.shared.pilots[deviceId].laps.append(CRFLap(lapTime: lapTimeValue, lapNumber: Int(lapNumberValue)))
                                    LDAppNotify.postNotification(NotificationCenterId.newTimeRecorded, object: nil as AnyObject?)
                                    
                                    let pilot = CRFData.shared.pilots[deviceId]
                                    
                                    if CRFData.shared.speakLapTimes && pilot.isEnabled
                                    {
                                        if CRFData.shared.skipFirstLap && Int(lapNumberValue) == 0
                                        {
                                            
                                        } else {
                                            let date = Date(timeIntervalSince1970: Double(lapTimeValue) / 1000)
                                            let formatter1 = DateFormatter()
                                            formatter1.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                                            
                                            formatter1.dateFormat = "m"
                                            let raceTimeMin = formatter1.string(from: date)
                                            
                                            let formatter2 = DateFormatter()
                                            formatter2.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                                            
                                            formatter2.dateFormat = "s"
                                            let raceTimeSec = formatter2.string(from: date)
                                            
                                            let formatter3 = DateFormatter()
                                            formatter3.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                                            
                                            formatter3.dateFormat = "SSSS"
                                            var raceTimeMili = formatter3.string(from: date)
                                            
                                            raceTimeMili = raceTimeMili.ldSubstring(from: 0 , to:1)
                                            
                                            if Constants.printMessageLogs
                                            {
                                                print("raceTimeMili \(raceTimeMili)")
                                            }
                                            
                                            if raceTimeMili == "00"
                                            {
                                                raceTimeMili = "0"
                                            }
                                            
                                            raceTimeMili = raceTimeMili.replacingOccurrences(of: "", with: " ")
                                            
                                            var text = raceTimeSec + " point " + raceTimeMili + " seconds"
                                            
                                            if raceTimeMin != "0"
                                            {
                                                text = raceTimeMin + " minutes " + text
                                            }
                                            
                                            var textToSay = pilot.getPilotName()
                                            
                                            var lapNumber = Int(lapNumberValue)
                                            if !CRFData.shared.skipFirstLap
                                            {
                                                lapNumber += 1
                                            }
                                            
                                            if lapNumber == CRFData.shared.lapsToGo
                                            {
                                                textToSay = textToSay + " finished"
                                            } else if lapNumber > CRFData.shared.lapsToGo
                                            {
                                                textToSay = textToSay + " already finished"
                                            }
                                            
                                            //print(textToSay + ". Lap \(lapNumber)" + ". " + text)
                                            
                                            if !CRFData.shared.setupInProgress
                                            {
                                                CRFUtility.speak(textToSay + ". Lap \(lapNumber)" + ". " + text)
                                            }
                                        }
                                    }
                                }
                            }
                            
                        case "C": //MARK: <C> channel ***Channel***
                            let pilot = CRFData.shared.pilots[deviceId]
                            let channel = command.ldSubstring(from: 3 , to:3)
                            
                            if let channelValue = UInt64(channel, radix: 16) {
                                pilot.channelId = Int(channelValue)
                            }
                            
                        case "B": //MARK: <B> band ***Band***
                            let pilot = CRFData.shared.pilots[deviceId]
                            let band = command.ldSubstring(from: 3 , to:4)
                            
                            if let bandValue = UInt64(band, radix: 16) {
                                pilot.bandId = Int(bandValue)
                            }
                            
                        case "M": //MARK: <M> minLapTime ***Min Lap Time***
                            let minLapTime = command.ldSubstring(from: 3 , to:4)
                            
                            if let minLapTimeValue = UInt64(minLapTime, radix: 16) {
                                CRFData.shared.minLapTime = Int(minLapTimeValue)
                            }
                            
                        case "T": //MARK: <T> threshold ***Threshold***
                            let pilot = CRFData.shared.pilots[deviceId]
                            let threshold = command.ldSubstring(from: 3 , to:6)
                            
                            if let thresholdValue = UInt64(threshold, radix: 16) {
                                pilot.threshold = Int(thresholdValue)
                            }
                            LDAppNotify.postNotification(NotificationCenterId.thresholdUpdated, object: nil as AnyObject?)
                            
                        case "S": //MARK: <S> deviceSound ***Enable/Disable Sounds***
                            let deviceSoundEnabled = command.ldSubstring(from: 3 , to:3)
                            
                            if deviceSoundEnabled == "0"
                            {
                                CRFData.shared.deviceSoundEnabled = false
                            } else {
                                CRFData.shared.deviceSoundEnabled = true
                            }
                            
                        case "1": //MARK: <1> skipFirstLap ***Skip/Enable First Lap***
                            let skipFirstLapEnabled = command.ldSubstring(from: 3 , to:3)
                            
                            if skipFirstLapEnabled == "0"
                            {
                                CRFData.shared.skipFirstLap = false
                            } else {
                                CRFData.shared.skipFirstLap = true
                            }
                            
                        case "y": //MARK: <y> isDeviceConfigured ***Was device configured***
                            let isDeviceConfigured = command.ldSubstring(from: 3 , to:3)
                            if isDeviceConfigured == "0"
                            {
                                CRFData.shared.pilots[deviceId].isDeviceConfigured = false
                                
                                if Constants.printMessageLogs
                                {
                                    print("*********isDeviceConfigured NO")
                                }
                                
                                let bandId = UserDefaults.standard.integer(forKey: "Device\(deviceId)Band")
                                let channelId = UserDefaults.standard.integer(forKey: "Device\(deviceId)Channel")
                                let threshold = UserDefaults.standard.integer(forKey: "Device\(deviceId)Threshold")
                                
                                CRFSendCommandManager.shared.sendMessage(String(format: "R\(deviceId)"+Command.setThresholdValue+"%04X",threshold))
                                CRFSendCommandManager.shared.sendMessage("R\(deviceId)"+Command.setChannel+"\(channelId)")
                                CRFSendCommandManager.shared.sendMessage("R\(deviceId)"+Command.setBand+"\(bandId)")
                                
                            } else {
                                CRFData.shared.pilots[deviceId].isDeviceConfigured = true
                                
                                if Constants.printMessageLogs
                                {
                                    print("******************isDeviceConfigured YES")
                                }
                            }
                            
                        case "R": //MARK: <R> Race state ***Start Race/End Race***
                            let raceState = command.ldSubstring(from: 3 , to:3)
                            if raceState == "0"
                            {
                                CRFData.shared.raceIsOn = false
                            } else {
                                CRFData.shared.raceIsOn = true
                            }
                            
                        case "v": //MARK: <v> voltageReading ***Get LiPo Voltage***
                            let voltage = command.ldSubstring(from: 3 , to:6)
                            
                            if let voltageValue = UInt64(voltage, radix: 16) {
                                CRFData.shared.voltage = Int(voltageValue)
                            }
                            LDAppNotify.postNotification(NotificationCenterId.voltageUpdated, object: nil as AnyObject?)
                            
                        case "t": //MARK: <t> calibrationTime
                            let timeNeeded = command.ldSubstring(from: 3 , to:10)
                            
                            if let timeNeededValue = Int32(timeNeeded, radix: 16)
                            {
                                if CRFData.shared.pilots[deviceId].calibrationTime1 == -1
                                {
                                    CRFData.shared.pilots[deviceId].calibrationTime1 = Int32(timeNeededValue)
                                } else {
                                    CRFData.shared.pilots[deviceId].calibrationTime2 = Int32(timeNeededValue)
                                    LDAppNotify.postNotification(NotificationCenterId.calibrationTimeReceved, object: nil as AnyObject?)
                                }
                            }
                            
                        case "H": //MARK: <H> reportStageChanged
                            let reportStage = command.ldSubstring(from: 3 , to:3)
                            
                            if let reportStageValue = Int(reportStage) {
                                
                                CRFData.shared.pilots[deviceId].calibrationStage = reportStageValue
                                LDAppNotify.postNotification(NotificationCenterId.reportStageChanged, object: nil as AnyObject?)
                            }
                            
                        case "F": //MARK: <F> frequency
                            let frequency = command.ldSubstring(from: 3 , to:6)
                            if let frequencyValue = Int32(frequency, radix: 16)
                            {
                                if Constants.printMessageLogs
                                {
                                    print("frequency: \(frequencyValue)")
                                }
                                
                                if deviceId == 0
                                {
                                    LDAppNotify.postNotification(NotificationCenterId.frequencyChangedSpectrum, object: frequencyValue as AnyObject?)
                                }
                            }
                            
                        case "x": //MARK: <x> Calibration
                            LDUtility.ldDelay(2.0)
                            {
                                CRFData.shared.setupInProgress = false
                            }
                        case "#": //MARK: <#> API VERSION
                            let apiVersion = command.ldSubstring(from: 3 , to:6)
                            
                            if let apiVersionValue = UInt64(apiVersion, radix: 16) {
                                if Constants.printMessageLogs
                                {
                                    print("API VERSION: \(apiVersionValue)")
                                }
                                
                                if apiVersionValue != Constants.lastAPIVersion
                                {
                                    LDDialog.showDialog(message: "Node(\(deviceId) has API VERSION: \(apiVersionValue))", title: "API VERSION ERROR")
                                }
                                
                                CRFData.shared.pilots[deviceId].apiVersion = Int(apiVersionValue)
                            }
                            
                        case "I": //MARK: <I> RSSI Monitoring Interval
                            let monitorInterval = command.ldSubstring(from: 3 , to:6)
                            
                            if let monitorIntervalValue = UInt64(monitorInterval, radix: 16)
                            {
                                if Constants.printMessageLogs
                                {
                                    print("RSSI Monitoring Interval: \(monitorIntervalValue)")
                                }
                            }
                            
                        default:
                            if Constants.printMessageLogs
                            {
                                print("Command not parsed:")
                                print(thirdChar)
                            }
                        }
                    }
                } else if firstChar == "R"
                {
                    
                }
            }
        }
        CRFMessageParser.btMessage = ""
    }
}
