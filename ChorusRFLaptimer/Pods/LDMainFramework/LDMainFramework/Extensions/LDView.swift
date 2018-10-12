//
//  LDView.swift
//
//  Created by Lazar on 9/20/17.
//  Copyright © 2017 Lazar. All rights reserved.
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
    open class func ldLoadFromNib<T : UIView>(named nibName:String, into viewHolder:UIView? = nil) -> T?
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
            let topConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: viewHolder, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            let bottomConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: viewHolder, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
            let leftConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: viewHolder, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: 0)
            let rightConstraint = NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.trailing, relatedBy: NSLayoutRelation.equal, toItem: viewHolder, attribute: NSLayoutAttribute.trailing, multiplier: 1, constant: 0)
            
            viewHolder.addConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
        }
        return view
    }
    
    /// Method for fetching first responder inside given UIView
    ///
    /// - Parameter view: UIVIew inside which we are looking for a first responder
    /// - Returns: Found first responder
    open static func ldFindFirstResponder(inView view: UIView) -> UIView? {
        for subView in view.subviews
        {
            if subView.isFirstResponder {
                return subView
            }
            if let recursiveSubView = self.ldFindFirstResponder(inView: subView)
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
    open func ldAnimatedChangeAlpha(toValue value: CGFloat, animationDuration: Double)
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
    open func ldSetBorder(borderWidth:CGFloat, borderColor:UIColor)
    {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    /// Set circled corners of view. Setting will be performed with some delay, because in some cases view frame is unknown.
    open func ldSetCircled()
    {
        self.perform(#selector(ldSetCircleDelayed), with: nil, afterDelay: 0.001)
    }
    
    /// Set circled corners of view based on its frame.
    @objc private func ldSetCircleDelayed()
    {
        self.ldSetCornerRadius(cornerRadius: self.frame.size.width * 0.5)
    }
    
    /// Set rounded corners of view.
    ///
    /// - Parameter cornerRadius: CGFloat value of corner radius of view.
    open func ldSetCornerRadius(cornerRadius:CGFloat)
    {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
}
