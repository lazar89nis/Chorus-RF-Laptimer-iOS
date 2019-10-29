//
//  GraphVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 10/20/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import UIKit
import SwiftChart
import HCFramework

class GraphVC: UIViewController,ChartDelegate {

    var deviceNumber: Int = 0

    @IBOutlet weak var chart: Chart!
    
    // MARK: - view controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.AppUtility.lockOrientation(.landscapeLeft)

        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Go Back", style:.done, target:self, action:#selector(goBack))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        self.title = "RSSI Graph Device\(deviceNumber+1)"

        chart.delegate = self
        reloadGraph()
        chart.minY = 0
        chart.maxY = 350
        chart.showXLabelsAndGrid = false
        chart.yLabels = [0,25,50,75,100,125,150,175,200,225,250,275,300,325,350]
        chart.bottomInset = 0
        
        HCAppNotify.observeNotification(self, selector: #selector(reloadGraph), name: NotificationCenterId.RSSISupdated)
        HCAppNotify.observeNotification(self, selector: #selector(serialDidDisconnect), name: NotificationCenterId.serialDidDisconnect)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.AppUtility.lockOrientation(.portrait)
    }
    
    @objc func goBack()
    {
        self.navigationController?.hcGoBack()
    }
    
    // MARK: - notifications
    
    @objc func serialDidDisconnect()
    {
        HCAppNotify.removeObserver(self)
        goBack()
    }
    
    @objc func reloadGraph()
    {
        chart.removeAllSeries()
        let series = ChartSeries(CRFData.shared.pilots[deviceNumber].RSSIS)
        series.color = UIColor.hcColorWithHex("244ACE")
        series.area = true
        chart.add(series)
        
        let maxValue = CRFData.shared.pilots[deviceNumber].findMaxRSSI()
        
        self.title = "Device\(deviceNumber+1) - Max RSSI: \(Int(maxValue))"
    }

    // MARK: - Chart
    
    func didTouchChart(_ chart: Chart, indexes: [Int?], x: Double, left: CGFloat){}
    
    func didFinishTouchingChart(_ chart: Chart) {}
    
    func didEndTouchingChart(_ chart: Chart) {}
}
