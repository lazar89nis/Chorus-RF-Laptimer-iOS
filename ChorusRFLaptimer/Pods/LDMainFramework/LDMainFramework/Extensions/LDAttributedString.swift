//
//  LDAttributedString.swift
//
//  Created by Lazar on 9/26/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit

// MARK: - NSAttributedString extension
extension NSAttributedString
{
    /// Calculate height of attributed string for specific font, the width text occupies and specific number of line.
    ///
    /// - Parameters:
    ///   - font: AttributedString Font
    ///   - width: The width that the AttributedString occupies
    ///   - lineNumber: number of lines for AttributedString
    /// - Returns: Height of AttributedString
    open func ldTextHeight(font:UIFont, width:CGFloat, lineNumber: Int) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = lineNumber
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.attributedText = self
        
        label.sizeToFit()
        return label.frame.height
    }
}
