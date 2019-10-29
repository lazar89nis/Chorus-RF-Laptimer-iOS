//
//  UDPManager.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 11/30/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import UIKit
import HCFramework
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
        
        HCAppNotify.postNotification(NotificationCenterId.serialDidDisconnect, object: nil as AnyObject?)
        HCAppNotify.postNotification(NotificationCenterId.reloadTableData, object: nil as AnyObject?)
        HCAppNotify.postNotification(NotificationCenterId.setScanButtonState, object: true as AnyObject?)

        HCUtility.hcDelay(2)
        {
            self.tryToConnect()
        }
    }
    
    func tryToConnect()
    {
        
        do {
            broadcastConnection = try UDPBroadcastConnection(
                port: 9000,
                handler: { [weak self] (ipAddress: String, port: Int, response: Data) -> Void in
                    guard let self = self else { return }
                    //let hexString = self.hexBytes(data: response)
                    //let utf8String = String(data: response, encoding: .utf8) ?? ""
                    
                    if let myResponse = String(bytes: response, encoding: .utf8)
                    {
                        let myResponse = myResponse.components(separatedBy: "\0")
                        
                        if self.firstMessage
                        {
                            HCAppNotify.postNotification(NotificationCenterId.UDPConnected, object: nil)
                            HCAppNotify.postNotification(NotificationCenterId.showHudWithText, object: "Connected to WiFi module!" as AnyObject?)
                        }
                        
                        CRFMessageParser.parsMessage(myResponse[0])
                        
                        self.firstMessage = false
                    }
                    
                    
                    //print("UDP connection received from \(ipAddress):\(port):\n\(hexString)\n\(utf8String)\n")
                    //print("Received from \(ipAddress):\(port):\n\(hexString)\n\(utf8String)\n")
                },
                errorHandler: { [weak self] (error) in
                    guard let self = self else { return }
                    print("Error: \(error)\n")
            })
        } catch {
            print("Error: \(error)\n")
        }
        
        
        /*broadcastConnection = UDPBroadcastConnection(port: 9000) { [unowned self] (response: (ipAddress: String, port: Int, response: [UInt8])) -> Void in
            
            if let myResponse = String(bytes: response.response, encoding: .utf8)
            {
                let myResponse = myResponse.components(separatedBy: "\0")
                
                if self.firstMessage
                {
                    HCAppNotify.postNotification(NotificationCenterId.UDPConnected, object: nil)
                    HCAppNotify.postNotification(NotificationCenterId.showHudWithText, object: "Connected to WiFi module!" as AnyObject?)
                }
                
                CRFMessageParser.parsMessage(myResponse[0])
                
                self.firstMessage = false
            }
        }*/
        
        do {
            try broadcastConnection.sendBroadcast(Command.enumerateDevices+"0"+Constants.wifiCommandEscapeSequence)
            //log("Sent: '\(Config.Strings.broadcastMessage)'\n")
        } catch {
            print("Error: \(error)\n")
        }
        
    }
    
    func sendMessage(_ myMessage: String)
    {
        do {
            try broadcastConnection.sendBroadcast(myMessage+Constants.wifiCommandEscapeSequence)
            //log("Sent: '\(Config.Strings.broadcastMessage)'\n")
        } catch {
            print("Error: \(error)\n")
        }
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
