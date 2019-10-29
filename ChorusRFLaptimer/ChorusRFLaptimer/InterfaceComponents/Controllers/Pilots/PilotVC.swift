//
//  PilotVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/26/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import HCFramework
import MKColorPicker

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
        
        HCAppNotify.observeNotification(self, selector: #selector(thresholdUpdated), name: NotificationCenterId.thresholdUpdated)
        HCAppNotify.observeNotification(self, selector: #selector(serialDidDisconnect), name: NotificationCenterId.serialDidDisconnect)
        HCAppNotify.observeNotification(self, selector: #selector(reportStageChanged), name: NotificationCenterId.reportStageChanged)
        HCAppNotify.observeNotification(self, selector: #selector(colorPressed(_:)), name: NotificationCenterId.setColorPressed)
        HCAppNotify.observeNotification(self, selector: #selector(rxEnableChanged), name: NotificationCenterId.rxEnableChanged)

        
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
            calibratePilotsButton.backgroundColor = UIColor.hcColorWithHex("717171")
        } else {
            calibratePilotsButton.isEnabled = true
            calibratePilotsButton.backgroundColor = UIColor.hcColorWithHex("2C4594")
        }
    }
    //MARK: - Helpers
    func showColorPicker(rect:CGRect, deviceId:Int)
    {
        let colorPicker = ColorPickerViewController()
        colorPicker.autoDismissAfterSelection = true
        colorPicker.scrollDirection = .horizontal
        colorPicker.style = .square
        colorPicker.pickerSize = CGSize(width: CGFloat(250), height: CGFloat(150))
        
        colorPicker.allColors = Constants.pilotColor
        
        colorPicker.selectedColor = { color in            
            var i = 0
            for colorObj in Constants.pilotColor
            {
                if colorObj == color
                {
                    break
                }
                i += 1
            }
            
            CRFSendCommandManager.shared.sendMessage(Command.ledSetColor+"\(deviceId)\(i)")
            
            HCUtility.hcDelay(0.5)
            {
                CRFSendCommandManager.shared.sendMessage(Command.ledCheckColors)
            }
            
            UserDefaults.standard.setValue(i, forKey: "\(UserDefaultsId.pilotColorIndex)\(deviceId)")
            
            self.pilotTableView.reloadData()
        }
        
        let buttonOffset = rect.origin.y + UIScreen.main.bounds.width/50 + UIScreen.main.bounds.width*0.0267
        var posY = buttonOffset + self.pilotTableView.frame.origin.y - self.pilotTableView.contentOffset.y + 44
        posY += UIScreen.main.bounds.width * 0.568 * CGFloat(deviceId)
        
        if let popoverController = colorPicker.popoverPresentationController{
            popoverController.delegate = colorPicker
            popoverController.permittedArrowDirections = .any
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: rect.origin.x, y: posY, width: rect.width, height: rect.height)
        }
        //colorPicker.modalPresentationStyle = .fullScreen FIXME: check if needed

        self.present(colorPicker, animated: true, completion: nil)
    }
    
    // MARK: - IBActions

    @IBAction func calibratePilotsButtonPressed(_ sender: Any) {
        CRFSendCommandManager.shared.sendMessage("R*"+Command.setupThresholdMode+"1")
    }
    
    // MARK: - notifications
    
    @objc func rxEnableChanged()
    {
        pilotTableView.reloadData()
    }
    
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
    
    @objc func colorPressed(_ notification:NSNotification)
    {
        if let object = notification.object as? [String: Any] {
        
            if let bounds = object["bounds"] as? CGRect {
                if let pilotId = object["pilotId"] as? Int {
                    showColorPicker(rect: bounds, deviceId: pilotId)
                }
            }
        }
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
        print(UIScreen.main.bounds.width*0.568)
        return UIScreen.main.bounds.width*0.568
    }
}
