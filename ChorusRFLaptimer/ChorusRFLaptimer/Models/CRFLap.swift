//
//  CRFLap.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 10/13/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit

class CRFLap: NSObject {

    var lapTime: UInt64 = 0
    var lapNumber: Int = 0

    init(lapTime: UInt64, lapNumber: Int)
    {
        self.lapTime = lapTime
        self.lapNumber = lapNumber
    }
    
}
