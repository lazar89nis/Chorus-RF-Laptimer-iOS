//
//  UDPManager.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 11/30/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit
import LDMainFramework
import SystemConfiguration.CaptiveNetwork

class CRFUDPManager: NSObject {
    
    private var firstMessage = true
    
    var broadcastConnection: UDPBroadcastConnection!

    static let shared: CRFUDPManager = {
        let instance = CRFUDPManager()
        
        return instance
    }()
    
    func discounectClient()
    {
        if broadcastConnection != nil
        {
            broadcastConnection.closeConnection()
            broadcastConnection.responseSource = nil
        }
        firstMessage = true
    }
    
    func connect()
    {
        discounectClient()
        
        CRFData.shared.resetPilots(0)
        
        LDAppNotify.postNotification(NotificationCenterId.serialDidDisconnect, object: nil as AnyObject?)
        LDAppNotify.postNotification(NotificationCenterId.reloadTableData, object: nil as AnyObject?)
        LDAppNotify.postNotification(NotificationCenterId.setScanButtonState, object: true as AnyObject?)

        LDUtility.ldDelay(2)
        {
            self.tryToConnect()
        }
    }
    
    func tryToConnect()
    {
        broadcastConnection = UDPBroadcastConnection(port: 9000) { [unowned self] (ipAddress: String, port: Int, response: [UInt8]) -> Void in
            
            if let myResponse = String(bytes: response, encoding: .utf8)
            {
                let myResponse = myResponse.components(separatedBy: "\0")
                
                if self.firstMessage
                {
                    LDAppNotify.postNotification(NotificationCenterId.UDPConnected, object: nil)
                    LDAppNotify.postNotification(NotificationCenterId.showHudWithText, object: "Connected to WiFi module!" as AnyObject?)
                }
                
                CRFMessageParser.parsMessage(myResponse[0])
                
                self.firstMessage = false
            }
        }
        
        broadcastConnection.sendBroadcast(Command.enumerateDevices+"0"+Constants.wifiCommandEscapeSequence)
    }
    
    func sendMessage(_ myMessage: String)
    {
        broadcastConnection.sendBroadcast(myMessage+Constants.wifiCommandEscapeSequence)
    }
    
    func printCurrentWifiInfo() -> String {
        if let interface = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interface) {
                let interfaceName: UnsafeRawPointer = CFArrayGetValueAtIndex(interface, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                if let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString), let interfaceData = unsafeInterfaceData as? [String : AnyObject] {
                    // connected wifi
                    return interfaceData["SSID"] as! String;
                } else {
                    // not connected wifi
                }
            }
        }
        return "";
    }
}
