//
//  PilotVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/26/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import LDMainFramework

class PilotVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    @IBOutlet weak var noDeviceL: UILabel!
    @IBOutlet weak var noDeviceI: UIImageView!
    @IBOutlet weak var pilotTableView: UITableView!
    @IBOutlet weak var calibratePilotsButton: UIButton!
    
    // MARK: - view controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        pilotTableView.delegate = self
        pilotTableView.dataSource = self
        
        pilotTableView.register(UINib(nibName: CellId.pilotTVC, bundle:nil), forCellReuseIdentifier: CellId.pilotTVC)
        
        LDAppNotify.observeNotification(self, selector: #selector(thresholdUpdated), name: NotificationCenterId.thresholdUpdated)
        LDAppNotify.observeNotification(self, selector: #selector(serialDidDisconnect), name: NotificationCenterId.serialDidDisconnect)
        LDAppNotify.observeNotification(self, selector: #selector(reportStageChanged), name: NotificationCenterId.reportStageChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        CRFSendCommandManager.shared.sendMessage("R*"+Command.rssiMonitor+"0050")
        
        pilotTableView.reloadData()
        
        if CRFData.shared.pilots.count < 1
        {
            calibratePilotsButton.isEnabled = false
            calibratePilotsButton.backgroundColor = UIColor.ldColorWithHex("717171")
        } else {
            calibratePilotsButton.isEnabled = true
            calibratePilotsButton.backgroundColor = UIColor.ldColorWithHex("2C4594")
        }
    }
    
    // MARK: - IBActions

    @IBAction func calibratePilotsButtonPressed(_ sender: Any) {
        CRFSendCommandManager.shared.sendMessage("R*"+Command.setupThresholdMode+"1")
    }
    
    // MARK: - notifications
    
    @objc func reportStageChanged()
    {
        pilotTableView.reloadData()
    }
    
    @objc func serialDidDisconnect()
    {
        pilotTableView.reloadData()
    }
    
    @objc func thresholdUpdated()
    {
        pilotTableView.reloadData()
    }
    
    // MARK: - table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if CRFData.shared.numberOfDevices == 0
        {
            noDeviceL.isHidden = false
            noDeviceI.isHidden = false
        } else {
            noDeviceL.isHidden = true
            noDeviceI.isHidden = true
        }
        
        return CRFData.shared.numberOfDevices
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PilotTVC = tableView.dequeueReusableCell(withIdentifier: CellId.pilotTVC, for: indexPath) as! PilotTVC
        
        cell.setupCell(deviceNumber: indexPath.row)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width*0.568
    }
}
