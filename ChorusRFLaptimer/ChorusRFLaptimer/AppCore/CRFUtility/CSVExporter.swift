//
//  CSVExporter.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/29/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import SwiftCSVExport

class CSVExporter: NSObject {

    static func exportData() -> String
    {
        // CSV rows Array
        let data:NSMutableArray  = NSMutableArray()
        
        for pilot in CRFData.shared.pilots
        {
            for lap in pilot.laps
            {
                let oneRow:NSMutableDictionary = NSMutableDictionary()
                
                var lapNumberVal = lap.lapNumber
                if !CRFData.shared.skipFirstLap
                {
                    lapNumberVal += 1
                }
                
                oneRow.setObject(lapNumberVal, forKey: Constants.exportCSVFieldLap as NSCopying)
                oneRow.setObject(pilot.getPilotName(), forKey: Constants.exportCSVFieldPilot as NSCopying)
                oneRow.setObject(pilot.formatRaceTime(milisecounds: lap.lapTime), forKey: Constants.exportCSVFieldTime as NSCopying)
                
                data.add(oneRow)
            }
        }

        // CSV fields Array
        let fields:NSMutableArray = NSMutableArray()
        fields.add(Constants.exportCSVFieldLap)
        fields.add(Constants.exportCSVFieldPilot)
        fields.add(Constants.exportCSVFieldTime)
        
        // Create a object for write CSV
        let writeCSVObj = CSV()
        writeCSVObj.rows = data
        writeCSVObj.delimiter = DividerType.comma.rawValue
        writeCSVObj.fields = fields as NSArray
        writeCSVObj.name = "myFile"

        let result = exportCSV(writeCSVObj);
        if result.isSuccess {
            guard let filePath =  result.value else {
                print("Export Error: \(String(describing: result.value))")
                return ""
            }
            
            return filePath
        } else {
            print("Export Error: \(String(describing: result.value))")
        }
        
        return ""
    }
}
