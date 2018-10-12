//
//  SetupVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/14/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import AVFoundation
import LDMainFramework
import PKHUD

class SetupVC: UIViewController {
    
    private var calibrationInProgress = false
    private var canWarnVoltage: Bool = true
    private var adjustVoltageHidden = true

    @IBOutlet weak var speakMessages: UISwitch!
    @IBOutlet weak var speakLapTimes: UISwitch!
    @IBOutlet weak var deviceSound: UISwitch!
    @IBOutlet weak var skipFirstLap: UISwitch!
    @IBOutlet weak var timeToPrepareStepper: UIStepper!
    @IBOutlet weak var timeToPrepareLabel: UILabel!
    @IBOutlet weak var minimumLapTimeStepper: UIStepper!
    @IBOutlet weak var minimumLapTimeLabel: UILabel!
    @IBOutlet weak var lapsToGoStepper: UIStepper!
    @IBOutlet weak var lapsToGoLabel: UILabel!
    @IBOutlet weak var adjustVoltageHeight: NSLayoutConstraint!
    @IBOutlet weak var adjustVoltageLabel: UILabel!
    @IBOutlet weak var adjustVoltageStepper: UIStepper!
    @IBOutlet weak var lipoTouchView: UIView!
    @IBOutlet weak var lipoProgress: UIProgressView!
    @IBOutlet weak var lipoVoltage: UILabel!
    @IBOutlet weak var lipoSwitch: UISwitch!
    @IBOutlet weak var calibrationNote: UILabel!
    @IBOutlet weak var calibrateDevicesButton: UIButton!
    @IBOutlet weak var phoneSleepSwitch: UISwitch!
    
    // MARK: - view controller functions
        
    override func viewDidLoad() {
        super.viewDidLoad()

        CRFUtility.setupAudioSounds()
        
        adjustVoltageHeight.constant = 0
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        lipoTouchView.addGestureRecognizer(longPressRecognizer)
        
        LDAppNotify.observeNotification(self, selector: #selector(calibrationTimeReceved), name: NotificationCenterId.calibrationTimeReceved)
        LDAppNotify.observeNotification(self, selector: #selector(voltageUpdated), name: NotificationCenterId.voltageUpdated)
        LDAppNotify.observeNotification(self, selector: #selector(serialDidDisconnect), name: NotificationCenterId.serialDidDisconnect)
        
        checkVoltage()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        phoneSleepSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsId.phoneSleep)
        UIApplication.shared.isIdleTimerDisabled = UserDefaults.standard.bool(forKey: UserDefaultsId.phoneSleep)
        
        speakMessages.isOn = CRFData.shared.speakMessages
        speakLapTimes.isOn = CRFData.shared.speakLapTimes
        deviceSound.isOn = CRFData.shared.deviceSoundEnabled
        timeToPrepareStepper.value = Double(CRFData.shared.timeToPrepareForRace)
        timeToPrepareLabel.text = "\(CRFData.shared.timeToPrepareForRace)"
        skipFirstLap.isOn = CRFData.shared.skipFirstLap
        minimumLapTimeStepper.value = Double(CRFData.shared.minLapTime)
        minimumLapTimeLabel.text = "\(CRFData.shared.minLapTime) sec."
        lapsToGoStepper.value = Double(CRFData.shared.lapsToGo)
        lapsToGoLabel.text = "\(CRFData.shared.lapsToGo)"
        
        adjustVoltageLabel.text = "\(CRFData.shared.voltageAdjustment)"
        adjustVoltageStepper.value = Double(CRFData.shared.voltageAdjustment)
        
        lipoSwitch.isOn = CRFData.shared.voltageMonitorOn
        
        if CRFData.shared.voltageMonitorOn
        {
            lipoTouchView.isHidden = false
        } else {
            lipoTouchView.isHidden = true
            adjustVoltageHidden = true
            adjustVoltageHeight.constant = 0
            
            self.view.layoutIfNeeded()
        }
        
        if CRFData.shared.numberOfDevices > 1
        {
            calibrateDevicesButton.isHidden = false
            calibrationNote.isHidden = true
        } else {
            calibrateDevicesButton.isHidden = true
            calibrationNote.isHidden = false
        }
    }
    
    // MARK: - touch gesture
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        if sender.state != UIGestureRecognizerState.began
        {
            return
        }
        
        if adjustVoltageHidden
        {
            adjustVoltageHidden = false
            adjustVoltageHeight.constant = UIScreen.main.bounds.width*0.13333
            
        } else {
            adjustVoltageHidden = true
            adjustVoltageHeight.constant = 0
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - notifications
    
    @objc func calibrationTimeReceved()
    {
        var allDone = true
        for pilot in CRFData.shared.pilots
        {
            if pilot.calibrationTime1 == -1 || pilot.calibrationTime2 == -1
            {
                allDone = false
            }
        }
        
        if allDone
        {
            calculateCalibration()
            
            HUD.show(HUDContentType.label("Calibration is done"))
            
            LDUtility.ldDelay(2)
            {
                HUD.hide()
                self.calibrationInProgress = false
            }
        }
    }
    
    @objc func voltageUpdated()
    {
        if !CRFData.shared.voltageMonitorOn || CRFData.shared.voltage == 0
        {
            return
        }
        
        let batteryVoltage = Double(CRFData.shared.voltage) * 11 * 5 * ((Double(CRFData.shared.voltageAdjustment) + 1000) / 1000) / 1024 //FIXME: This part looks bad
        let cellCount = Int(batteryVoltage/3.4)
        let cellVoltage = batteryVoltage/Double(cellCount)
        var percent = Int(((cellVoltage - 3.4) * 100 / (4.2 - 3.4)))
        
        if percent > 130
        {
            percent = 0
        } else if percent > 100
        {
            percent = 100
        }
        
        if CRFData.shared.speakMessages
        {
            if canWarnVoltage
            {
                var talkString = ""
                if percent <= 10
                {
                    talkString = "Device battery critical"
                } else if percent <= 20
                {
                    talkString = "Device battery low"
                }
                
                if talkString != ""
                {
                    CRFUtility.speak(talkString)
                    canWarnVoltage = false
                    
                    LDUtility.ldDelay(50)
                    {
                        self.canWarnVoltage = true
                    }
                }
            }
        }
        
        setVoltage(percent: percent, batteryVoltage: batteryVoltage)
    }
    
    @objc func serialDidDisconnect()
    {
        CRFData.shared.voltage = 0
        
        setVoltage(percent: 0, batteryVoltage: 0)
        checkVoltage()
    }
    
    // MARK: - helpers
    
    func calculateCalibration()
    {
        for pilot in CRFData.shared.pilots
        {
            let timeSpan =  pilot.calibrationTime2 - pilot.calibrationTime1
            let calculation = Constants.calibrateWaitTime/(Constants.calibrateWaitTime - timeSpan)

            CRFSendCommandManager.shared.sendMessage(String(format: "R\(pilot.pilotID)"+Command.setTimeAdjustmentValue+"%08X",calculation))
        }
    }
    
    func checkVoltage()
    {
        LDUtility.ldDelay(10)
        {
            self.checkVoltage()
        }
        
        if CRFData.shared.voltageMonitorOn
        {
            CRFSendCommandManager.shared.sendMessage("R*"+Command.liPoVoltage)
        }
    }

    func setVoltage(percent:Int, batteryVoltage:Double)
    {
        lipoVoltage.text = String(format: "%.2fV \(percent)", batteryVoltage)+"%"
        
        lipoProgress.progress = Float(Double(percent)/100.0)
        
        if percent >= 50
        {
            lipoProgress.progressTintColor = UIColor.ldColorWithHex("64c12c")
        } else if percent <= 50 && percent >= 30  {
            lipoProgress.progressTintColor = UIColor.ldColorWithHex("c1bc2c")
        } else if percent < 30 {
            lipoProgress.progressTintColor = UIColor.ldColorWithHex("c12c2c")
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func speakMessagesPressed(_ sender: UISwitch) {
        
        CRFData.shared.speakMessages = sender.isOn
        
        UserDefaults.standard.setValue(sender.isOn, forKey: UserDefaultsId.speakMessages)
    }
    
    @IBAction func speakLapTimesPressed(_ sender: UISwitch) {
        
        CRFData.shared.speakLapTimes = sender.isOn
        
        UserDefaults.standard.setValue(sender.isOn, forKey: UserDefaultsId.speakLapTimes)
        
    }
    
    @IBAction func deviceSoundPressed(_ sender: UISwitch) {
        
        if sender.isOn
        {
            CRFSendCommandManager.shared.sendMessage("R*"+Command.sound+"1")
        } else {
            CRFSendCommandManager.shared.sendMessage("R*"+Command.sound+"0")
        }
        
        CRFData.shared.deviceSoundEnabled = sender.isOn
    }
    
    @IBAction func skipFirstLapPressed(_ sender: UISwitch) {
        
        if sender.isOn
        {
            CRFSendCommandManager.shared.sendMessage("R*"+Command.skipFirstLap+"1")
        } else {
            CRFSendCommandManager.shared.sendMessage("R*"+Command.skipFirstLap+"0")
        }
        
        CRFData.shared.skipFirstLap = sender.isOn
    }
    
    @IBAction func timeToPrepareStepperPressed(_ sender: UIStepper) {
        
        timeToPrepareLabel.text = "\(Int(sender.value)) sec."
        
        CRFData.shared.timeToPrepareForRace = Int(sender.value)
        
        UserDefaults.standard.setValue(Int(sender.value), forKey: UserDefaultsId.timeToPrepareForRace)
    }
    
    
    @IBAction func minimumLapTimeStepperPressed(_ sender: UIStepper) {
        
        let value = Int(sender.value)
        minimumLapTimeLabel.text = "\(value) sec."
        
        CRFSendCommandManager.shared.sendMessage(String(format: "R*"+Command.setMinLapTime+"%02X",value))
        
        CRFData.shared.minLapTime = value
    }
    
    
    @IBAction func lapsToGoStepperPressed(_ sender: UIStepper) {
        
        lapsToGoLabel.text = "\(Int(sender.value))"
        
        CRFData.shared.lapsToGo = Int(sender.value)
        
        UserDefaults.standard.setValue(Int(sender.value), forKey: UserDefaultsId.lapsToGo)
    }
    
    
    @IBAction func adjustVoltageStepperPressed(_ sender: UIStepper) {
        
        adjustVoltageLabel.text = "\(Int(sender.value))"
        
        CRFData.shared.voltageAdjustment = Int(sender.value)
        
        UserDefaults.standard.setValue(Int(sender.value), forKey: UserDefaultsId.voltageAdjustment)
        
        voltageUpdated()
    }
    
    @IBAction func lipoSwitchChanged(_ sender: UISwitch) {
        
        if sender.isOn
        {
            lipoTouchView.isHidden = false
        } else {
            lipoTouchView.isHidden = true
            adjustVoltageHidden = true
            adjustVoltageHeight.constant = 0
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
        
        CRFData.shared.voltageMonitorOn = sender.isOn
        
        UserDefaults.standard.setValue(sender.isOn, forKey: UserDefaultsId.voltageMonitorOn)
        
        voltageUpdated()
    }
    
    @IBAction func calibrateDevicesButtonPressed(_ sender: Any) {
        
        HUD.show(HUDContentType.progress)
        calibrationInProgress = true
        for pilot in CRFData.shared.pilots
        {
            pilot.calibrationTime1 = -1
            pilot.calibrationTime2 = -1
        }
        
        
        CRFSendCommandManager.shared.sendMessage("R*"+Command.calibration)
        
        LDUtility.ldDelay(Double(Constants.calibrateWaitTime/1000))
        {
            CRFSendCommandManager.shared.sendMessage("R*"+Command.calibration)
        }
        
        LDUtility.ldDelay(Double((Constants.calibrateWaitTime+7000)/1000))
        {
            if self.calibrationInProgress
            {
                HUD.show(HUDContentType.label("Calibration failed. Try again"))
                LDUtility.ldDelay(2)
                {
                    HUD.hide()
                    self.calibrationInProgress = false
                }
            }
        }
    }
    
    @IBAction func phoneSleepChanged(_ sender: UISwitch) {
        UIApplication.shared.isIdleTimerDisabled = sender.isOn
        
        UserDefaults.standard.setValue(sender.isOn, forKey: UserDefaultsId.phoneSleep)
    }
    
}
