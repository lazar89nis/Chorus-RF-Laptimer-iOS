//
//  LDString.swift
//
//  Created by Lazar on 9/20/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit

// MARK: - String extension
extension String
{
    /// Calculate height of string for specific font, the width text occupies and specific number of line.
    ///
    /// - Parameters:
    ///   - font: String Font
    ///   - width: The width that the String occupies
    ///   - lineNumber: number of lines for String
    /// - Returns: Height of string
    public func ldTextHeight(font:UIFont, width:CGFloat, lineNumber: Int) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = lineNumber
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = self
        
        label.sizeToFit()
        return label.frame.height
    }
    
    
    /// Calculate width of string for the height text occupies and text font
    ///
    /// - Parameters:
    ///   - height: Text height
    ///   - font: Text font
    /// - Returns: Calculated text width
    public func ldTextWidth(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        return ceil(boundingBox.width)
    }
    
    /// Return substring from start position to end position of string.
    ///
    /// - Parameters:
    ///   - from: Index of substring start position in the original string
    ///   - to: Index of substring end position in the original string
    /// - Returns: Substring object
    public func ldSubstring(from: Int?, to: Int?) -> String {
        
        if let start = from {
            guard start < self.count else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.count {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }

    /// Return substring from start position to the end of string.
    ///
    /// - Parameter from: Index of substring start position in the original string
    /// - Returns: Substring object
    public func ldSubstring(from: Int) -> String {
        return self.ldSubstring(from: from, to: nil)
    }
    
    /// Return substring from the beginning of the string to end position of string.
    ///
    /// - Parameter to: Index of substring end position in the original string
    /// - Returns: Substring object
    public func ldSubstring(to: Int) -> String {
        return self.ldSubstring(from: nil, to: to)
    }
    
    /// Return substring with specific length from specified start position of substring in original string
    ///
    /// - Parameters:
    ///   - from: Index of substring start position in the original string
    ///   - length: Value that contains number of characters in substring starting from 'from' position.
    /// - Returns: Substring object
    public func ldSubstring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.ldSubstring(from: from, to: end)
    }
    
    /// Return substring with specific length where last character in substring is on 'to' position
    ///
    /// - Parameters:
    ///   - length: Substring length
    ///   - to: Index of last character in substring
    /// - Returns: Substring object
    public func ldSubstring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.ldSubstring(from: start, to: to)
    }

    /// Remove all the whitespace in string, and new lines if 'withNewLines' param is set to true.
    ///
    /// - Parameter withNewLines: Value that determines whether new lines are removed from the original string. Default value is false.
    /// - Returns: Trimed String object
    public func ldTrim(withNewLines: Bool = false) -> String {
        
        if withNewLines
        {
            return self.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else
        {
            return self.trimmingCharacters(in: .whitespaces)
        }
    }
}
