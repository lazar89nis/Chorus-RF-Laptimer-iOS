//
//  SendCommandManager.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 11/30/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit

struct Command
{
    static let skipFirstLap = "1"
    static let bulkDeviceState = "a"
    static let setBand = "B"
    static let setChannel = "C"
    static let setFrequency = "F"
    static let setupThresholdMode = "H"
    static let rssiMonitor = "I"
    static let setTimeAdjustmentValue = "J"
    static let setMinLapTime = "M"
    static let enumerateDevices = "N"
    static let currentRSSSI = "r"
    static let race = "R"
    static let sound = "S"
    static let calibration = "t"
    static let setThresholdValue = "T"
    static let liPoVoltage = "v"
}

class CRFSendCommandManager: NSObject
{
    static let shared: CRFSendCommandManager = {
        let instance = CRFSendCommandManager()
        
        return instance
    }()
    
    func sendMessage(_ message: String)
    {
        if CRFUDPManager.shared.broadcastConnection != nil && CRFUDPManager.shared.broadcastConnection.responseSource != nil
        {
            CRFUDPManager.shared.sendMessage(message)
        } else if CRFBTManager.shared.selectedPeripheral != nil
        {
            CRFBTManager.shared.sendMessage(message)
        } else {
            print("App not connected");
        }
    }
    
}
