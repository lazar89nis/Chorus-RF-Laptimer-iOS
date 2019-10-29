//
//  BTManager.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 10/12/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import CoreBluetooth
import HCFramework

class CRFBTManager: NSObject, BluetoothSerialDelegate, CBPeripheralDelegate {

    /// The peripherals that have been discovered (no duplicates and sorted by asc RSSI)
    var peripherals: [(peripheral: CBPeripheral, RSSI: Float)] = []
    
    /// The peripheral the user has selected
    var selectedPeripheral: CBPeripheral?
    
    var selectedPeripheralRssi: NSNumber = 0
    
    static let shared: CRFBTManager = {
        let instance = CRFBTManager()
        
        serial = BluetoothSerial(delegate: instance)
        
        return instance
    }()
    
    func sendMessage(_ msg:String)
    {
        if serial.connectedPeripheral != nil
        {
            serial.sendMessageToDevice(msg+Constants.btCommandEscapeSequence)
        }
    }
    
    func startScan()
    {
        serial.startScan()
    }
    
    func stopScan()
    {
        serial.stopScan()
    }
    
    func disconnect()
    {
        serial.disconnect()
        selectedPeripheral = nil
    }
    
    func connectToPeripheral()
    {
        if selectedPeripheral != nil
        {
            serial.connectToPeripheral(selectedPeripheral!)
        }
        startRSSI()
    }
    
    func getBTState() -> CBManagerState
    {
        return serial.centralManager.state
    }
    
    func getConnectedPeripheral() -> CBPeripheral?
    {
        return serial.connectedPeripheral
    }
    
    func isConnected() -> Bool
    {
        if let _ = selectedPeripheral {
            return true
        }
        return false
    }
    
    //MARK: BluetoothSerialDelegate
    
    func serialDidDiscoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber?)
    {
        // check whether it is a duplicate
        for exisiting in peripherals {
            if exisiting.peripheral.identifier == peripheral.identifier { return }
        }
        
        // add to the array, next sort & reload
        let theRSSI = RSSI?.floatValue ?? 0.0
        peripherals.append((peripheral: peripheral, RSSI: theRSSI))
        peripherals.sort { $0.RSSI < $1.RSSI }
        
        HCAppNotify.postNotification(NotificationCenterId.reloadTableData, object: nil as AnyObject?)
    }
    
    func serialDidReceiveString(_ message: String) {
        CRFMessageParser.parsMessage(message)
    }
    
    func serialDidFailToConnect(_ peripheral: CBPeripheral, error: NSError?)
    {
        HCAppNotify.postNotification(NotificationCenterId.setScanButtonState, object: true as AnyObject?)

        HCAppNotify.postNotification(NotificationCenterId.showHudWithText, object: "Failed to connect" as AnyObject?)
    }
    
    func serialDidDisconnect(_ peripheral: CBPeripheral, error: NSError?)
    {
        CRFData.shared.resetPilots(0)
        
        HCAppNotify.postNotification(NotificationCenterId.serialDidDisconnect, object: nil as AnyObject?)
        
        HCAppNotify.postNotification(NotificationCenterId.reloadTableData, object: nil as AnyObject?)
        
        HCAppNotify.postNotification(NotificationCenterId.setScanButtonState, object: true as AnyObject?)

        HCAppNotify.postNotification(NotificationCenterId.showHudWithText, object: "Bluetooth Disconnect" as AnyObject?)
    }
    
    func serialIsReady(_ peripheral: CBPeripheral)
    {
        HCAppNotify.postNotification(NotificationCenterId.reloadTableData, object: nil as AnyObject?)
        
        HCAppNotify.postNotification(NotificationCenterId.showHudWithText, object: "Connected" as AnyObject?)
        HCAppNotify.postNotification(NotificationCenterId.startBTRSSI, object: nil as AnyObject?)

        CRFSendCommandManager.shared.sendMessage(Command.enumerateDevices+"0")
    }
    
    func serialDidChangeState() {
        HCAppNotify.postNotification(NotificationCenterId.hideHud, object: nil as AnyObject?)
        
        if serial.centralManager.state != .poweredOn {
            HCAppNotify.postNotification(NotificationCenterId.setScanButtonState, object: false as AnyObject?)

            HCAppNotify.postNotification(NotificationCenterId.setStatusText, object: "Bluetooth not turned on" as AnyObject?)
        } else if serial.centralManager.state == .poweredOn
        {
            HCAppNotify.postNotification(NotificationCenterId.setScanButtonState, object: true as AnyObject?)

            HCAppNotify.postNotification(NotificationCenterId.setStatusText, object: "Bluetooth is turned on" as AnyObject?)
        }
    }
    
    func startRSSI()
    {
        HCUtility.hcDelay(3)
        {
            self.updateRSSI()
        }
    }
    
    
    func updateRSSI()
    {
        if !isConnected()
        {
            return
        }
        
        serial.readRSSI()
        
        HCUtility.hcDelay(1)
        {
            self.updateRSSI()
        }
    }
    
    func serialDidReadRSSI(_ rssi: NSNumber)
    {
        selectedPeripheralRssi = rssi
        HCAppNotify.postNotification(NotificationCenterId.reloadTableData, object: nil as AnyObject?)
    }
}
