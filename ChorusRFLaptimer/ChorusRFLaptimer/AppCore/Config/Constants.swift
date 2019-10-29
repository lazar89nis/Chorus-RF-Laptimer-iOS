//
//  Constants.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/27/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import HCFramework

struct BandFreq
{
    var band: String
    var freq: [Int]
}

class Constants: NSObject
{
    static let frequencies: [BandFreq] = [BandFreq(band:"R", freq: [5658,5695,5732,5769,5806,5843,5880,5917]),
                                          BandFreq(band:"A", freq: [5865,5845,5825,5805,5785,5765,5745,5725]),
                                          BandFreq(band:"B", freq: [5733,5752,5771,5790,5809,5828,5847,5866]),
                                          BandFreq(band:"E", freq: [5705,5685,5665,5645,5885,5905,5925,5945]),
                                          BandFreq(band:"F", freq: [5740,5760,5780,5800,5820,5840,5860,5880]),
                                          BandFreq(band:"D", freq: [5362,5399,5436,5473,5510,5547,5584,5621]),
                                          BandFreq(band:"Connex1", freq: [5180,5200,5220,5240,5745,5765,5785,5805]),
                                          BandFreq(band:"Connex2", freq: [5825,5845,5845,5845,5845,5845,5845,5845])]
    
    static var pilotColor:[UIColor] = [UIColor.red,
                            UIColor.yellow,
                            UIColor.green,
                            UIColor.blue,
                            UIColor.orange,
                            UIColor(red: 0, green: 255/255.0, blue: 255/255.0, alpha: 1.0),
                            UIColor.purple,
                            UIColor(red: 255/255.0, green: 0, blue: 208/255.0, alpha: 1.0)]
    
    /*static let pilotColor: [UIColor] = [UIColor.hcColorWithHex("4ECDC4"),
                                        UIColor.hcColorWithHex("C7F464"),
                                        UIColor.hcColorWithHex("FF6B6B"),
                                        UIColor.hcColorWithHex("C44D58"),
                                        UIColor.hcColorWithHex("3E4CB2"),
                                        UIColor.hcColorWithHex("049652"),
                                        UIColor.hcColorWithHex("6F8206"),
                                        UIColor.hcColorWithHex("F7C683")]*/
    
    static let exportCSVFieldLap = "LAP"
    static let exportCSVFieldPilot = "PILOT"
    static let exportCSVFieldTime = "TIME"
    
    static let btCommandEscapeSequence = "\n\r\n"
    static let wifiCommandEscapeSequence = "\n"
    
    static let printMessageLogs = false
    
    static let calibrateWaitTime: Int32 = 10000
    
    static let RSSIGraphMinValue = 130
    static let RSSIGraphMaxValue = 310
    
    static let lastAPIVersion = 6
}
