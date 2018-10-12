//
//  PilotTVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/26/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import LDMainFramework

class PilotTVC: UITableViewCell {

    var treshold = 150
    var deviceNumber: Int = 0
    
    @IBOutlet weak var stageLabel: UILabel!
    @IBOutlet weak var greyView: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    @IBOutlet weak var showGraphButton: UIButton!
    @IBOutlet weak var pilotTitleLabel: UILabel!
    @IBOutlet weak var pilotNameTextField: UITextField!
    @IBOutlet weak var colorRibon: UIView!
    @IBOutlet weak var tresholdStepper: UIStepper!
    @IBOutlet weak var tresholdLabel: UILabel!
    @IBOutlet weak var rssiThresholdLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var enableSwitch: UISwitch!
    @IBOutlet weak var signalLabel: UILabel!
    @IBOutlet weak var signalProgressView: UIProgressView!
    
    // MARK: - cell setup
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        LDAppNotify.observeNotification(self, selector: #selector(updateRSSI), name: NotificationCenterId.RSSIchanged)
        
        pilotNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let longGestureClearButton = UILongPressGestureRecognizer(target: self, action: #selector(longPressedClearButton))
        longGestureClearButton.minimumPressDuration = 0
        clearButton.addGestureRecognizer(longGestureClearButton)
        
        let longGestureTresholdLabel = UILongPressGestureRecognizer(target: self, action: #selector(longPressedTresholdLabel))
        longGestureTresholdLabel.minimumPressDuration = 1
        tresholdLabel.addGestureRecognizer(longGestureTresholdLabel)
        tresholdLabel.isUserInteractionEnabled = true
        
        let longGestureRssiThresholdLabel = UILongPressGestureRecognizer(target: self, action: #selector(longPressedTresholdLabel))
        longGestureRssiThresholdLabel.minimumPressDuration = 1
        rssiThresholdLabel.addGestureRecognizer(longGestureRssiThresholdLabel)
        rssiThresholdLabel.isUserInteractionEnabled = true
    }
    
    func setupCell(deviceNumber: Int)
    {
        self.deviceNumber = deviceNumber
        
        colorRibon.backgroundColor = Constants.pilotColor[deviceNumber]
        
        let pilot = CRFData.shared.pilots[deviceNumber]
        pilotTitleLabel.text = "Channel: #\(pilot.channelId+1) (\(Constants.frequencies[pilot.bandId].band) band) \(Constants.frequencies[pilot.bandId].freq[pilot.channelId])MHz"
        pilotNameTextField.text = pilot.name
        
        treshold = pilot.threshold
        enableSwitch.isOn = pilot.isEnabled
        
        tresholdLabel.text = "\(treshold)"
        tresholdStepper.value = Double(treshold)
        
        if CRFData.shared.pilots[deviceNumber].calibrationStage == 0
        {
            clearButton.setTitle("Start", for: .normal)
        } else {
            clearButton.setTitle("Stop", for: .normal)
        }
        
        if deviceNumber == CRFData.shared.numberOfDevices-1
        {
            bottomSeparator.isHidden = false
        } else {
            bottomSeparator.isHidden = true
        }
        
        if pilot.isEnabled
        {
            showGraphButton.isEnabled = true
            greyView.isHidden = true
        } else {
            greyView.isHidden = false
            showGraphButton.isEnabled = false
        }
        
        updateRSSI()
        updateStageLabel()
    }
    
    // MARK: - IBActions
    
    @IBAction func showGraphPressed(_ sender: Any) {
        
        let graphVC: GraphVC = UINavigationController.ldGetNC().ldGetVCForIdentifier(ViewControllerId.graphVC, storyBoardName: StoryboardId.mainStoryboard) as! GraphVC
        
        graphVC.deviceNumber = deviceNumber
        
        UINavigationController.ldGetNC().ldOpenVC(graphVC)
    }

    @IBAction func tresholdStepperPressed(_ sender: UIStepper) {
        
        treshold = Int(sender.value)
        tresholdLabel.text = "\(treshold)"
        
        CRFData.shared.pilots[deviceNumber].threshold = treshold
        
        CRFSendCommandManager.shared.sendMessage(String(format: "R\(deviceNumber)"+Command.setThresholdValue+"%04X",treshold))
        
        UserDefaults.standard.setValue(treshold, forKey: "Device\(deviceNumber)Threshold")
    }

    @IBAction func enableSwitchPressed(_ sender: UISwitch) {
        
        CRFData.shared.pilots[deviceNumber].isEnabled = sender.isOn
        
        if sender.isOn
        {
            showGraphButton.isEnabled = true
            greyView.isHidden = true
        } else {
            greyView.isHidden = false
            showGraphButton.isEnabled = false
        }
    }

    // MARK: - helpers
    
    func updateStageLabel()
    {
        if CRFData.shared.pilots[deviceNumber].calibrationStage == 0
        {
            stageLabel.text = "Not Running/Done"
        } else if CRFData.shared.pilots[deviceNumber].calibrationStage == 1
        {
            stageLabel.text = "Running"
        } else if CRFData.shared.pilots[deviceNumber].calibrationStage == 2
        {
            stageLabel.text = "Halfway"
        }
    }
    
    func setSignal(_ signal: Int)
    {
        signalLabel.text = "\(signal)"
        
        signalProgressView.progress = Float(signal)/350.0
        
        if signal > CRFData.shared.pilots[deviceNumber].threshold
        {
            signalProgressView.progressTintColor = UIColor.ldColorWithHex("c12c2c");
        } else {
            signalProgressView.progressTintColor = UIColor.ldColorWithHex("244ACE");
        }
    }
    
    // MARK: - text field
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        CRFData.shared.pilots[deviceNumber].name = textField.text!
        
        UserDefaults.standard.setValue(textField.text!, forKey: "Device\(deviceNumber)PilotName")
    }

    // MARK: - notifications
    
    @objc func updateRSSI()
    {
        setSignal(CRFData.shared.pilots[deviceNumber].RSSI)
    }
    
    // MARK: - touch gestures
    
    @objc func longPressedTresholdLabel(sender: UILongPressGestureRecognizer)
    {
        if sender.state != UIGestureRecognizerState.began
        {
            return
        }
        
        let alert = UIAlertController(title: "Threshold", message: "Enter a threshold value to set", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = UIKeyboardType.numberPad
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            if Int(textField!.text!) == nil {
                return;
            }
            
            self.treshold = Int(textField!.text!)!
            self.tresholdLabel.text = "\(self.treshold)"
            
            CRFData.shared.pilots[self.deviceNumber].threshold = self.treshold
            
            CRFSendCommandManager.shared.sendMessage(String(format: "R\(self.deviceNumber)"+Command.setThresholdValue+"%04X",self.treshold))
            
            UserDefaults.standard.setValue(self.treshold, forKey: "Device\(self.deviceNumber)Threshold")
        }))
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func longPressedClearButton(sender: UILongPressGestureRecognizer)
    {
        if sender.state != UIGestureRecognizerState.began
        {
            return
        }
        
        if CRFData.shared.pilots[deviceNumber].calibrationStage == 0
        {
            CRFSendCommandManager.shared.sendMessage("R\(deviceNumber)"+Command.setupThresholdMode+"1")
            clearButton.setTitle("Stop", for: .normal)
        } else {
            CRFSendCommandManager.shared.sendMessage("R\(deviceNumber)"+Command.setupThresholdMode+"0")
            clearButton.setTitle("Start", for: .normal)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
