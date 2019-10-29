//
//  SpectrumVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 6/22/18.
//  Copyright © 2018 Hypercube. All rights reserved.
//

import Foundation
import UIKit
import HCFramework
import SwiftChart

struct Spectrum
{
    var freq: Int
    var RSSI: Int
}

class SpectrumVC: UIViewController, ChartDelegate
{
    fileprivate var labelLeadingMarginInitialConstant: CGFloat!

    var minfreq: Int = 5645
    var maxfreq: Int = 5945
    var freq: Int = 5645
    var skipEvery: Int = 3
    var currentFreq: Int = 0
    var started: Bool = false
    var rssis: [(x: Double, y: Double)] = []

    @IBOutlet weak var chart: Chart!
    @IBOutlet weak var labelLeadingMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var fromMhzInput: UITextField!
    @IBOutlet weak var toMhzInput: UITextField!
    @IBOutlet weak var incrementMhzInput: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - view controller functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"Go Back", style:.done, target:self, action:#selector(goBack))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
        labelLeadingMarginInitialConstant = labelLeadingMarginConstraint.constant
        
        fromMhzInput.text = String(minfreq)
        toMhzInput.text = String(maxfreq)
        incrementMhzInput.text = String(skipEvery)

        chart.delegate = self
        chart.minY = Double(Constants.RSSIGraphMinValue)
        chart.maxY = Double(Constants.RSSIGraphMaxValue)
        chart.minX = Double(minfreq)
        chart.maxX = Double(maxfreq)
        chart.hideHighlightLineOnTouchEnd = true
        chart.showXLabelsAndGrid = true
        chart.xLabelsSkipLast = false
        chart.yLabels = [Double(Constants.RSSIGraphMinValue),160,190,220,250,280,Double(Constants.RSSIGraphMaxValue)]
        let step = (maxfreq - minfreq ) / 3
        chart.xLabels = [Double(minfreq), Double(minfreq + step), Double(minfreq + step + step), Double(maxfreq)]
        
        reloadGraph()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        HCAppNotify.observeNotification(self, selector: #selector(RSSIchangedSpectrum(_:)), name: NotificationCenterId.RSSIchangedSpectrum)
        HCAppNotify.observeNotification(self, selector: #selector(frequencyChangedSpectrum(_:)), name: NotificationCenterId.frequencyChangedSpectrum)
        
        CRFSendCommandManager.shared.sendMessage("R*"+Command.rssiMonitor+"0000")
    }
    
    // MARK: - IBAction
    
    @IBAction func startPressed(_ sender: Any) {
        
        if started
        {
            started = false
            
            startButton.setTitle("START", for: .normal)
            fromMhzInput.isEnabled = true
            toMhzInput.isEnabled = true
            incrementMhzInput.isEnabled = true
        } else {
            rssis.removeAll()
            reloadGraph()
            
            startButton.setTitle("STOP", for: .normal)
            fromMhzInput.isEnabled = false
            toMhzInput.isEnabled = false
            incrementMhzInput.isEnabled = false
            
            started = true
            
            if fromMhzInput.text != ""
            {
                minfreq = Int(fromMhzInput.text!)!
            }
            
            if toMhzInput.text != ""
            {
                maxfreq = Int(toMhzInput.text!)!
            }
            
            if incrementMhzInput.text != ""
            {
                skipEvery = Int(incrementMhzInput.text!)!
            }
            chart.minX = Double(minfreq)
            chart.maxX = Double(maxfreq)
            
            let step = (maxfreq - minfreq ) / 3
            
            chart.xLabels = [Double(minfreq), Double(minfreq + step), Double(minfreq + step + step), Double(maxfreq)]
            
            freq = minfreq
            
            CRFSendCommandManager.shared.sendMessage(String(format: "R0"+Command.setFrequency+"%04X",freq))
        }
    }
    
    // MARK: - helpers
    
    @objc func goBack()
    {
        self.navigationController?.hcGoBack()
    }
    
    func reloadGraph()
    {
        chart.removeAllSeries()
        
        var series = ChartSeries(data: rssis)
        
        if rssis.count == 0
        {
            series = ChartSeries(data: [(x:Double(minfreq) , y:Double(Constants.RSSIGraphMinValue))])
        }

        series.color = UIColor.hcColorWithHex("244ACE")
        series.area = true
        chart.add(series)
    }
    
    func changeFrequency()
    {
        if !started
        {
            return
        }
        
        if freq == maxfreq
        {
            freq = minfreq
        }
        
        CRFSendCommandManager.shared.sendMessage(String(format: "R0"+Command.setFrequency+"%04X",freq))
        
        freq += skipEvery
    }
    
    // MARK: - notifications

    @objc func RSSIchangedSpectrum(_ notification:NSNotification)
    {
        if !started
        {
            return
        }
        
        var RSSI: Int = notification.object as! Int
        //print(RSSI)
        
        if RSSI < Constants.RSSIGraphMinValue
        {
            RSSI = Constants.RSSIGraphMinValue
        } else if RSSI > Constants.RSSIGraphMaxValue
        {
            RSSI = Constants.RSSIGraphMaxValue
        }
        
        if currentFreq != 0
        {
            if currentFreq == minfreq
            {
                rssis.removeAll()
            }
            
            rssis.append((x:Double(currentFreq) , y:Double(RSSI)))
            
            reloadGraph()
            
            changeFrequency()
        }
    }
    
    @objc func frequencyChangedSpectrum(_ notification:NSNotification)
    {
        if !started
        {
            return
        }
        
        let frequency: Int = notification.object as! Int
     
        currentFreq = frequency
        
        CRFSendCommandManager.shared.sendMessage("R0"+Command.currentRSSSI)
    }
    
    // MARK: - Chart
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Double, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            
            let freq = minfreq + indexes[0]! * skipEvery
            
            label.text = "\(freq)Mhz - \(value)"
            
            var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
            
            if constant < labelLeadingMarginInitialConstant {
                constant = labelLeadingMarginInitialConstant
            }
            
            let rightMargin = chart.frame.width - label.frame.width
            if constant > rightMargin {
                constant = rightMargin
            }
            
            labelLeadingMarginConstraint.constant = constant
        }
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        label.text = ""
        labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
    }
    
    func didEndTouchingChart(_ chart: Chart) {
        label.text = ""
        labelLeadingMarginConstraint.constant = labelLeadingMarginInitialConstant
    }
}
