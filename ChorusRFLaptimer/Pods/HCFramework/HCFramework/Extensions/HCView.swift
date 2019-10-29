//
//  HCView.swift
//
//  Created by Hypercube on 9/20/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import UIKit

// MARK: - UIView extension
extension UIView {
    
    /// Generic method for instantiating a view from a nib (xib) file.
    ///
    /// - Parameters:
    ///   - nibName: String value for nib (xib) file name.
    ///   - viewHolder: UIView for view holder of nib view. By default viewHolder is not set.
    /// - Returns: UIView of generic type loaded from a nib (xib) file
    @discardableResult
    public class func hcLoadFromNib<T : UIView>(named nibName:String, into viewHolder:UIView? = nil) -> T?
    {
        if let viewHolder = viewHolder
        {
            for singleSubview in viewHolder.subviews
            {
                if singleSubview.isKind(of: self)
                {
                    return nil
                }
            }
        }
        
        guard let view = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as? T else
        {
            return nil
        }
        if let viewHolder = viewHolder
        {
            viewHolder.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            let topConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: viewHolder, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: viewHolder, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
            let leftConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: viewHolder, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: viewHolder, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
            
            viewHolder.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
        }
        return view
    }
    
    /// Method for fetching first responder inside given UIView
    ///
    /// - Parameter view: UIVIew inside which we are looking for a first responder
    /// - Returns: Found first responder
    public static func hcFindFirstResponder(inView view: UIView) -> UIView? {
        for subView in view.subviews
        {
            if subView.isFirstResponder {
                return subView
            }
            if let recursiveSubView = self.hcFindFirstResponder(inView: subView)
            {
                return recursiveSubView
            }
        }
        
        return nil
    }
    
    /// Animated change views' alpha
    ///
    /// - Parameters:
    ///   - value: Final alpha value for the view
    ///   - animationDuration: Animation duration
    public func hcAnimatedChangeAlpha(toValue value: CGFloat, animationDuration: Double)
    {
        UIView.animate(withDuration: animationDuration, animations: {
            self.alpha = value
        })
    }
    
    /// Set view border
    ///
    /// - Parameters:
    ///   - borderWidth: Border width
    ///   - borderColor: Border color
    public func hcSetBorder(borderWidth:CGFloat, borderColor:UIColor)
    {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    /// Set circled corners of view. Setting will be performed with some delay, because in some cases view frame is unknown.
    public func hcSetCircled()
    {
        self.perform(#selector(hcSetCircleDelayed), with: nil, afterDelay: 0.001)
    }
    
    /// Set circled corners of view based on its frame.
    @objc private func hcSetCircleDelayed()
    {
        self.hcSetCornerRadius(cornerRadius: self.frame.size.width * 0.5)
    }
    
    /// Set rounded corners of view.
    ///
    /// - Parameter cornerRadius: CGFloat value of corner radius of view.
    public func hcSetCornerRadius(cornerRadius:CGFloat)
    {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
