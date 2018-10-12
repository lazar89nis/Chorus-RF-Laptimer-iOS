//
//  Constants.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/27/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import LDMainFramework

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
    
    static let pilotColor: [UIColor] = [UIColor.ldColorWithHex("4ECDC4"),
                                        UIColor.ldColorWithHex("C7F464"),
                                        UIColor.ldColorWithHex("FF6B6B"),
                                        UIColor.ldColorWithHex("C44D58"),
                                        UIColor.ldColorWithHex("3E4CB2"),
                                        UIColor.ldColorWithHex("049652"),
                                        UIColor.ldColorWithHex("6F8206"),
                                        UIColor.ldColorWithHex("F7C683")]
    
    static let exportCSVFieldLap = "LAP"
    static let exportCSVFieldPilot = "PILOT"
    static let exportCSVFieldTime = "TIME"
    
    static let btCommandEscapeSequence = "\n\r\n"
    static let wifiCommandEscapeSequence = "\n"
    
    static let printMessageLogs = false
    
    static let calibrateWaitTime: Int32 = 10000
    
    static let RSSIGraphMinValue = 130
    static let RSSIGraphMaxValue = 310
    
    static let lastAPIVersion = 4
}
