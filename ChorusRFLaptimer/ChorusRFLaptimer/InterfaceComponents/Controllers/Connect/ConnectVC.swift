//
//  BluetoothVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/27/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import PKHUD
import HCFramework
import Crashlytics

class ConnectVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var scanTimer: Timer? = nil
    private var connectTimer: Timer? = nil
    private var wifiNameTimer: Timer? = nil
    
    @IBOutlet weak var btStatusView: UIView!
    @IBOutlet weak var devicesTableView: UITableView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var wifiInfoLabel: UILabel!
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var wifiButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!

    // MARK: - view controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let isBTMode = UserDefaults.standard.bool(forKey: UserDefaultsId.isBTMode)
        
        modeSwitch.isOn = isBTMode
        
        if isBTMode
        {
            showBTCommponents(state: true)
        } else {
            let networkName = CRFUDPManager.shared.printCurrentWifiInfo()
            wifiInfoLabel.text = "WiFi name: "+networkName
            
            showBTCommponents(state: false)
        }
        
        devicesTableView.delegate = self
        devicesTableView.dataSource = self
        
        devicesTableView.register(UINib(nibName: CellId.bluetoothTVC, bundle:nil), forCellReuseIdentifier: CellId.bluetoothTVC)
        
        scanButton.isEnabled = false
        
        wifiInfoLabel.isUserInteractionEnabled = true
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapFunction))
        tap.minimumPressDuration = 1
        wifiInfoLabel.addGestureRecognizer(tap)
        
        if CRFBTManager.shared.getBTState() != .poweredOn
        {
            statusLabel.text = "Bluetooth not turned on"
        } else if isBTMode
        {
            statusLabel.text = "Scanning..."
            CRFBTManager.shared.startScan()
            scanTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ConnectVC.scanTimeOut), userInfo: nil, repeats: false)
        }
        
        wifiNameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ConnectVC.updateWifiName), userInfo: nil, repeats: true)

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let networkName = CRFUDPManager.shared.printCurrentWifiInfo()
        wifiInfoLabel.text = "WiFi name: "+networkName
        
        devicesTableView.reloadData()
        
        HCAppNotify.observeNotification(self, selector: #selector(showHudWithText(_:)), name: NotificationCenterId.showHudWithText)
        HCAppNotify.observeNotification(self, selector: #selector(setScanButtonState(_:)), name: NotificationCenterId.setScanButtonState)
        HCAppNotify.observeNotification(self, selector: #selector(setStatusText(_:)), name: NotificationCenterId.setStatusText)
        HCAppNotify.observeNotification(self, selector: #selector(reloadTableData), name: NotificationCenterId.reloadTableData)
        HCAppNotify.observeNotification(self, selector: #selector(hideHud), name: NotificationCenterId.hideHud)
        HCAppNotify.observeNotification(self, selector: #selector(uDPConnected), name: NotificationCenterId.UDPConnected)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        HCAppNotify.removeObserver(self)
    }
    
    // MARK: - notifications
    
    @objc func showHudWithText(_ notification:NSNotification)
    {
        let text: String = notification.object as! String
        
        HUD.hide()
        
        HUD.show(HUDContentType.label(text))
        
        HCUtility.hcDelay(2)
        {
            HUD.hide()
        }
    }
    
    @objc func setScanButtonState(_ notification:NSNotification)
    {
        let state: Bool = notification.object as! Bool
        
        scanButton.isEnabled = state
    }
    
    @objc func setStatusText(_ notification:NSNotification)
    {
        let text: String = notification.object as! String
        
        statusLabel.text = text
    }
    
    @objc func reloadTableData()
    {
        devicesTableView.reloadData()
    }
    
    @objc func hideHud()
    {
        HUD.hide()
    }
    
    @objc func uDPConnected()
    {
        scanTimer!.invalidate()
    }
    
    // MARK: - gesture
    
    @objc func tapFunction(sender: UILongPressGestureRecognizer)
    {
        //UIApplication.shared.open(URL(string:"App-Prefs:root=WIFI")!, options: [:], completionHandler: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func modeChange(_ sender: UISwitch) {
        if sender.isOn
        {
            showBTCommponents(state: true)
        } else {
            showBTCommponents(state: false)
            
            let networkName = CRFUDPManager.shared.printCurrentWifiInfo()
            wifiInfoLabel.text = "WiFi name: "+networkName
        }
        UserDefaults.standard.setValue(sender.isOn, forKey: UserDefaultsId.isBTMode)
    }
    
    @IBAction func wifiConnectPressed(_ sender: Any)
    {
        let networkName = CRFUDPManager.shared.printCurrentWifiInfo()
        wifiInfoLabel.text = "WiFi name: "+networkName
        
        HUD.show(HUDContentType.label("Connecting..."))
        
        scanTimer = Timer.scheduledTimer(timeInterval: 7, target: self, selector: #selector(ConnectVC.udpScanTimeOut), userInfo: nil, repeats: false)

        wifiButton.setTitle("WIFI CONNECT",for: .normal)

        CRFUDPManager.shared.connect()
    }
    
    @IBAction func scanPressed(_ sender: Any)
    {
        CRFBTManager.shared.peripherals = []
        
        devicesTableView.reloadData()
        
        scanButton.isEnabled = false
        
        statusLabel.text = "Scanning..."
        
        CRFBTManager.shared.startScan()
        
        scanTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ConnectVC.scanTimeOut), userInfo: nil, repeats: false)
    }
    
    @IBAction func disconnectPressed(_ sender: Any)
    {
        if let _ = CRFBTManager.shared.selectedPeripheral {
            CRFBTManager.shared.disconnect()
            connectTimer!.invalidate()
        } else {
            HUD.show(HUDContentType.label("No device connected"))
            
            HCUtility.hcDelay(2)
            {
                HUD.hide()
            }
        }
    }
    
    // MARK: - helpers
    
    func showBTCommponents(state: Bool)
    {
        wifiButton.isHidden = state
        wifiInfoLabel.isHidden = state
        scanButton.isHidden = !state
        btStatusView.isHidden = !state
        devicesTableView.isHidden = !state
    }
    
    @objc func udpScanTimeOut()
    {
        wifiButton.setTitle("WIFI CONNECT",for: .normal)
        
        CRFUDPManager.shared.discounectClient()

        HUD.show(HUDContentType.label("Failed to connect to WiFi device"))
        
        HCUtility.hcDelay(2)
        {
            HUD.hide()
        }
    }
    
    @objc func scanTimeOut()
    {
        CRFBTManager.shared.stopScan()
        scanButton.isEnabled = true
        statusLabel.text = "Done scanning"
        
        HUD.show(HUDContentType.success)
        
        HCUtility.hcDelay(2)
        {
            HUD.hide()
        }
    }
    
    @objc func connectTimeOut()
    {
        // don't if we've already connected
        if let _ = CRFBTManager.shared.getConnectedPeripheral() {
            return
        }
        
        HUD.hide()
        
        if let _ = CRFBTManager.shared.selectedPeripheral {
            CRFBTManager.shared.disconnect()
        }
        
        HUD.show(HUDContentType.label("Failed to connect"))
        
        HCUtility.hcDelay(2)
        {
            HUD.hide()
        }
    }
    
    @objc func updateWifiName()
    {
        let networkName = CRFUDPManager.shared.printCurrentWifiInfo()
        wifiInfoLabel.text = "WiFi name: "+networkName
    }
    
    // MARK: - table
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return CRFBTManager.shared.peripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell: BluetoothTVC = tableView.dequeueReusableCell(withIdentifier: CellId.bluetoothTVC, for: indexPath) as! BluetoothTVC
        
        let peripheral = CRFBTManager.shared.peripherals[(indexPath as NSIndexPath).row].peripheral
        
        cell.setupCell(peripheral: peripheral)
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UIScreen.main.bounds.width*0.16
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        CRFBTManager.shared.stopScan()
        
        scanTimer!.invalidate()
        scanTimeOut()
        
        CRFBTManager.shared.selectedPeripheral = CRFBTManager.shared.peripherals[(indexPath as NSIndexPath).row].peripheral
        CRFBTManager.shared.connectToPeripheral()

        HUD.show(HUDContentType.label("Connecting..."))

        connectTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ConnectVC.connectTimeOut), userInfo: nil, repeats: false)
    }
}
