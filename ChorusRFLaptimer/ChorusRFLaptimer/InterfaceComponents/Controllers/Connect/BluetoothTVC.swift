//
//  BluetoothTVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/27/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import CoreBluetooth
import LDMainFramework

class BluetoothTVC: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var connectedLabel: UILabel!
    @IBOutlet weak var RSSILabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupCell(peripheral: CBPeripheral)
    {
        nameLabel.text = peripheral.name
        idLabel.text = peripheral.identifier.uuidString
        
        if let selectedPeripheral = CRFBTManager.shared.selectedPeripheral {
            if peripheral.identifier.uuidString == selectedPeripheral.identifier.uuidString && selectedPeripheral.state == CBPeripheralState.connected
            {
                connectedLabel.isHidden = false
            } else {
                connectedLabel.isHidden = true
            }
            RSSILabel.text = "RSSI: \(CRFBTManager.shared.selectedPeripheralRssi)"
        } else {
            connectedLabel.isHidden = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
