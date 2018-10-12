//
//  LDColor.swift
//
//  Created by Lazar on 9/20/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit

// MARK: - UIColor extension
extension UIColor
{
    /// Create the UIColor object from specific hex value of color which is passed in hex param.
    ///
    /// - Parameter hex: The date that contains date value.
    /// - Returns: UIColor object for specific hex value of color.
    static open func ldColorWithHex(_ hex:String) -> UIColor
    {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
