//
//  FreqTVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/26/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import HCFramework

class FreqTVC: UITableViewCell {

    var band: Int = 0
    var channel: Int = 0
    var deviceNumber: Int = 0
    
    @IBOutlet weak var colorRibon: UIView!
    @IBOutlet weak var channelLabel: UILabel!
    @IBOutlet weak var bandLabel: UILabel!
    @IBOutlet weak var signalLabel: UILabel!
    @IBOutlet weak var signalProgressView: UIProgressView!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var channelStepper: UIStepper!
    @IBOutlet weak var bandStepper: UIStepper!

    // MARK: - Setup
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        if deviceNumber == CRFData.shared.numberOfDevices-1
        {
            bottomSeparator.isHidden = false
        } else {
            bottomSeparator.isHidden = true
        }
        
        HCAppNotify.observeNotification(self, selector: #selector(updateRSSI), name: NotificationCenterId.RSSIchanged)
    }
    
    func setupCell(deviceNumber: Int)
    {
        self.deviceNumber = deviceNumber
        
        band = CRFData.shared.pilots[deviceNumber].bandId
        channel = CRFData.shared.pilots[deviceNumber].channelId
        
        bandStepper.value = Double(band)
        channelStepper.value = Double(channel)
        
        deviceName.text = "Device #\(deviceNumber)"
        bandLabel.text = Constants.frequencies[band].band
        channelLabel.text = "#\(channel+1) - \(Constants.frequencies[band].freq[channel])MHz"
        colorRibon.backgroundColor = Constants.pilotColor[UserDefaults.standard.integer(forKey: "\(UserDefaultsId.pilotColorIndex)\(deviceNumber)")]

        updateRSSI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - helpers
    
    func setSignal(_ signal: Int)
    {
        signalLabel.text = "\(signal)"
        
        signalProgressView.progress = Float(signal)/350.0
        
        if signal > CRFData.shared.pilots[deviceNumber].threshold
        {
            signalProgressView.progressTintColor = UIColor.hcColorWithHex("c12c2c");
        } else {
            signalProgressView.progressTintColor = UIColor.hcColorWithHex("244ACE");
        }
    }
    
    // MARK: - notifications
    
    @objc func updateRSSI()
    {
        setSignal(CRFData.shared.pilots[deviceNumber].RSSI)
    }
    
    // MARK: - IBActions
    
    @IBAction func channelStepperPressed(_ sender: UIStepper) {
        channel = Int(sender.value)
        
        channelLabel.text = "#\(channel+1) - \(Constants.frequencies[band].freq[channel])MHz"
        
        CRFSendCommandManager.shared.sendMessage("R\(deviceNumber)"+Command.setChannel+"\(channel)")
        
        CRFData.shared.pilots[deviceNumber].channelId = channel
        
        UserDefaults.standard.setValue(channel, forKey: "Device\(deviceNumber)Channel")
    }
    
    @IBAction func bandStepperPressed(_ sender: UIStepper) {
        band = Int(sender.value)
        
        bandLabel.text = Constants.frequencies[band].band
        channelLabel.text = "#\(channel+1) - \(Constants.frequencies[band].freq[channel])MHz"
        
        CRFSendCommandManager.shared.sendMessage("R\(deviceNumber)"+Command.setBand+"\(band)")
        
        CRFData.shared.pilots[deviceNumber].bandId = band
        
        UserDefaults.standard.setValue(band, forKey: "Device\(deviceNumber)Band")
    }
}
