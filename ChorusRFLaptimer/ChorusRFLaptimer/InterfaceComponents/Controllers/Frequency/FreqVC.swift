//
//  FreqVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/26/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import LDMainFramework

class FreqVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var noDeviceL: UILabel!
    @IBOutlet weak var noDeviceI: UIImageView!
    @IBOutlet weak var freqTableView: UITableView!
    
    // MARK: - view controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        freqTableView.delegate = self
        freqTableView.dataSource = self
        
        freqTableView.register(UINib(nibName: CellId.freqTVC, bundle:nil), forCellReuseIdentifier: CellId.freqTVC)

        LDAppNotify.observeNotification(self, selector: #selector(serialDidDisconnect), name: NotificationCenterId.serialDidDisconnect)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        CRFSendCommandManager.shared.sendMessage("R*"+Command.rssiMonitor+"0050")
        
        freqTableView.reloadData()
    }
    
    // MARK: - notifications
    
    @objc func serialDidDisconnect()
    {
        freqTableView.reloadData()
    }
    
    // MARK: - table view

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
        
        let cell: FreqTVC = tableView.dequeueReusableCell(withIdentifier: CellId.freqTVC, for: indexPath) as! FreqTVC
        
        cell.setupCell(deviceNumber: indexPath.row)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width*0.408
    }
}
