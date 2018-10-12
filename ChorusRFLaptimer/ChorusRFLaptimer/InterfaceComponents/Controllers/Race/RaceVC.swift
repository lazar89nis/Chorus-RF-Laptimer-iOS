//
//  RaceVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/27/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import FZAccordionTableView
import MessageUI
import LDMainFramework
import AVFoundation
import PKHUD

class RaceVC: UIViewController, FZAccordionTableViewDelegate,UITableViewDelegate, UITableViewDataSource,MFMailComposeViewControllerDelegate {
    
    var numberOfBips = 0
    
    @IBOutlet weak var sendButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var noDeviceL: UILabel!
    @IBOutlet weak var noDeviceI: UIImageView!
    @IBOutlet weak var raceTableView: FZAccordionTableView!
    @IBOutlet weak var startRaceButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - view controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        raceTableView.delegate = self
        raceTableView.dataSource = self
        
        raceTableView.allowMultipleSectionsOpen = true
        raceTableView.enableAnimationFix = true
        
        raceTableView.register(UINib(nibName: CellId.racePilotLapTVC, bundle:nil), forCellReuseIdentifier: CellId.racePilotLapTVC)
        raceTableView.register(UINib(nibName: CellId.racePilotTVC, bundle:nil), forHeaderFooterViewReuseIdentifier: CellId.racePilotTVC)
        
        sendButtonHeight.constant = 0
        
        LDAppNotify.observeNotification(self, selector: #selector(reloadTable), name: NotificationCenterId.newTimeRecorded)
        LDAppNotify.observeNotification(self, selector: #selector(serialDidDisconnect), name: NotificationCenterId.serialDidDisconnect)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        CRFData.shared.pilotsInRace.removeAll()
        
        for pilot in CRFData.shared.pilots
        {
            if pilot.isEnabled
            {
                CRFData.shared.pilotsInRace.append(pilot)
            }
        }
        
        raceTableView.reloadData()
        
        CRFSendCommandManager.shared.sendMessage("R*"+Command.rssiMonitor+"0000")
        
        if CRFData.shared.pilotsInRace.count < 1
        {
            startRaceButton.isEnabled = false
            startRaceButton.backgroundColor = UIColor.ldColorWithHex("717171")
        } else {
            startRaceButton.isEnabled = true
            startRaceButton.backgroundColor = UIColor.ldColorWithHex("2C4594")
        }
        
        if CRFData.shared.raceIsOn
        {
            startRaceButton.setTitle("STOP RACE", for: .normal)
            sendButtonHeight.constant = 0
            //UIApplication.shared.isIdleTimerDisabled = true
        } else {
            //UIApplication.shared.isIdleTimerDisabled = false
            
            startRaceButton.setTitle("START RACE (\(CRFData.shared.pilotsInRace.count)PILOTS)", for: .normal)
            numberOfBips = 0
            
            if CRFData.shared.checkIfThereIsRaceResaults()
            {
                sendButtonHeight.constant = UIScreen.main.bounds.width*0.1253
            }
        }
        
        if CRFData.shared.pilotsInRace.count < 1
        {
            sendButtonHeight.constant = 0
        }
    }
    
    // MARK: - notifications

    @objc func serialDidDisconnect()
    {
        startRaceButton.isEnabled = false
        startRaceButton.backgroundColor = UIColor.ldColorWithHex("717171")
        raceTableView.reloadData()
    }
    
    @objc func reloadTable()
    {
        raceTableView.reloadData()
    }
    
    // MARK: - helpers
    
    func beepSound()
    {
        if CRFData.shared.timeToPrepareForRace-numberOfBips-1 <= 0
        {
            HUD.show(HUDContentType.label("GO"))
            startRace()
        } else {
            HUD.show(HUDContentType.label("Race start in: \(CRFData.shared.timeToPrepareForRace-numberOfBips-1)"))
        }
        
        if CRFData.shared.timeToPrepareForRace == self.numberOfBips + 1
        {
            CRFUtility.playBeepSound(false)
        } else {
            CRFUtility.playBeepSound(true)
        }
        numberOfBips += 1
        
        LDUtility.ldDelay(0.3)
        {
            if CRFData.shared.timeToPrepareForRace <= self.numberOfBips + 1
            {
                LDUtility.ldDelay(1.5)
                {
                    HUD.hide()
                }
            }
        }
        
        LDUtility.ldDelay(1)
        {
            if CRFData.shared.timeToPrepareForRace > self.numberOfBips
            {
                self.beepSound()
            }
        }
    }
    
    func startRace()
    {
        //UIApplication.shared.isIdleTimerDisabled = true
        
        startRaceButton.setTitle("STOP RACE", for: .normal)
        CRFSendCommandManager.shared.sendMessage("R*"+Command.race+"1")
        CRFData.shared.raceIsOn = true
    }
    
    // MARK: - email
    
    func sendMail(_ path: String)
    {
        if MFMailComposeViewController.canSendMail()
        {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            
            let dateFormater = DateFormatter()
            dateFormater.timeZone = NSTimeZone(name: "UTC") as TimeZone?
            dateFormater.dateFormat = "dd.MM.yyyy HH:mm:ss"
            
            let dateString = dateFormater.string(from: Date())
            
            //Set the subject and message of the email
            mailComposer.setSubject("Chorus RF Laptimer Race Data")
            mailComposer.setMessageBody("This is race data from " + dateString, isHTML: false)
            
            if let fileData = NSData(contentsOfFile: path) {
                mailComposer.addAttachmentData(fileData as Data, mimeType: "text/csv", fileName: dateString+"-raceData")
            }
            
            self.navigationController?.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction func sendButtonPressed(_ sender: Any)
    {
        let dataUrl = CSVExporter.exportData()
        sendMail(dataUrl)
    }
    
    @IBAction func startRacePressed(_ sender: Any) {
        if CRFData.shared.raceIsOn
        {
            //UIApplication.shared.isIdleTimerDisabled = false

            numberOfBips = 0
            
            startRaceButton.setTitle("START RACE (\(CRFData.shared.pilotsInRace.count)PILOTS)", for: .normal)
            CRFSendCommandManager.shared.sendMessage("R*"+Command.race+"0")
            CRFData.shared.raceIsOn = false
            
            if CRFData.shared.checkIfThereIsRaceResaults()
            {
                sendButtonHeight.constant = UIScreen.main.bounds.width*0.1253
            }
        } else {
            startRaceButton.setTitle("PREPARE...", for: .normal)
            
            CRFData.shared.resetPilotTimes()
            raceTableView.reloadData()
            beepSound()

            sendButtonHeight.constant = 0
        }
    }
    
    // MARK: - table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CRFData.shared.pilotsInRace[section].laps.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if CRFData.shared.numberOfDevices == 0
        {
            noDeviceL.isHidden = false
            noDeviceI.isHidden = false
        } else {
            noDeviceL.isHidden = true
            noDeviceI.isHidden = true
        }
        
        return CRFData.shared.pilotsInRace.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width*0.08
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UIScreen.main.bounds.width*0.488
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0;
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let backgroundView = UIView(frame: CGRect.zero)
        backgroundView.backgroundColor = UIColor(white: 1, alpha: 1)
        return backgroundView
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView(tableView, heightForRowAt: indexPath)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.tableView(tableView, heightForHeaderInSection:section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellId.racePilotLapTVC, for: indexPath) as! RacePilotLapTVC
        
        let pilot = CRFData.shared.pilotsInRace[indexPath.section]
        let lap = pilot.laps[indexPath.row]
        
        cell.setLapTime(lapNumber: lap.lapNumber, lapTime: lap.lapTime, pilot: pilot)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell: RacePilotTVC = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellId.racePilotTVC) as! RacePilotTVC
        let pilot = CRFData.shared.pilotsInRace[section]

        let backgroundView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = UIColor(white: 1, alpha: 1)
        cell.backgroundView = backgroundView
       
        cell.setupCell(deviceNumber: section, pilot: pilot, colorRibonColor: Constants.pilotColor[pilot.pilotID])

        return cell
    }
    
    func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {}
    
    func tableView(_ tableView: FZAccordionTableView, didOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {}
    
    func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {}
    
    func tableView(_ tableView: FZAccordionTableView, didCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {}
    
    func tableView(_ tableView: FZAccordionTableView, canInteractWithHeaderAtSection section: Int) -> Bool {
        return true
    }
}
