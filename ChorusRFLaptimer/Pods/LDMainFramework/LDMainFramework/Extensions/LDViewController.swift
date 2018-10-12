//
//  LDViewController.swift
//
//  Created by Lazar on 9/20/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit

/// Completion handler without parameters
public typealias EmptyCompletionHandler = () -> Void

/// Completion handler with one numerical parameter
public typealias CompletionNumberHandler = (CGFloat) -> Void

/// Completion handler with two numerical parameters
public typealias CompletionTwoNumbersHandler = (CGFloat, CGFloat) -> Void

// MARK: - UIViewController extension
extension UIViewController
{
    // MARK: - Set up navigation bar
    
    /// Hide navigation bar
    open func ldHideNavigationBar()
    {
        self.ldSetNavigationBar(hidden: true)
    }
    
    /// Show navigation bar
    open func ldShowNavigationBar()
    {
        self.ldSetNavigationBar(hidden: false)
    }
    
    /// Clear navigation stack
    open func ldClearNavigationStack()
    {
        self.navigationController?.ldClearAllPreviousPages()
    }
    
    
    /// Hide or show navigation bar
    ///
    /// - Parameter hidden: Defines if navigation bar is hidden or not
    open func ldSetNavigationBar(hidden:Bool)
    {
        self.navigationController?.isNavigationBarHidden = hidden
    }
    
    /// Generate empty navigation bar icon
    ///
    /// - Returns: Generated empty navigation bar icon
    open func generateEmptyNavigationBarIcon() -> UIImage
    {
        func getImageWithColor(color: UIColor, size: CGSize) -> UIImage
        {
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            color.setFill()
            UIRectFill(rect)
            let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return image
        }
        let scale = UIScreen.main.scale
        return getImageWithColor(color: .clear, size: CGSize(width: 25.0*scale, height: 25.0*scale))
    }
    
    /// Set navigation bar background color
    ///
    /// - Parameter backgroundColor: Navigation bar background color
    open func ldSetNavigationbarBackgroundColor(backgroundColor:UIColor?)
    {
        if let backgroundColor = backgroundColor
        {
            self.navigationController?.navigationBar.barTintColor = backgroundColor
            self.navigationController?.navigationBar.backgroundColor = backgroundColor
        }
    }
    
    /// Set navigation bar button items
    ///
    /// - Parameters:
    ///   - leftIcon: Left icon image for the navigaton bar
    ///   - leftAction: Left action for the navigaton bar
    ///   - rightIcon: Right icon image for the navigaton bar
    ///   - rightAction: Right action for the navigaton bar
    open func ldSetNavigationBar(leftIcon:UIImage? = nil, leftAction:Selector?, rightIcon:UIImage? = nil, rightAction:Selector?)
    {
        self.ldShowNavigationBar()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: leftIcon ?? self.generateEmptyNavigationBarIcon(), style: .plain, target: self, action: leftAction)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: rightIcon ?? self.generateEmptyNavigationBarIcon(), style: .plain, target: self, action: rightAction)
    }
    
    /// Set navigation bar title and navigation bar button items
    ///
    /// - Parameters:
    ///   - backgroundColor: Navigation bar background color
    ///   - title: Navigation bar title
    ///   - font: Navigation bar title font
    ///   - titleColor: Navigation bar title color
    ///   - leftIcon: Left icon image for the navigaton bar
    ///   - leftAction: Left action for the navigaton bar
    ///   - rightIcon: Right icon image for the navigaton bar
    ///   - rightAction: Right action for the navigaton bar
    open func ldSetNavigationBar(backgroundColor:UIColor? = nil, title:String = "", font:UIFont? = nil, titleColor:UIColor? = nil, leftIcon:UIImage? = nil, leftAction:Selector? = nil, rightIcon:UIImage? = nil, rightAction:Selector? = nil)
    {
        self.ldSetNavigationbarBackgroundColor(backgroundColor: backgroundColor)
        if let font = font
        {
            let headerLabel = UILabel()
            headerLabel.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 33.0)
            headerLabel.textAlignment = .center
            headerLabel.text = title
            headerLabel.font = font
            headerLabel.sizeToFit()
            if let titleColor = titleColor
            {
                headerLabel.textColor = titleColor
            }
            self.navigationItem.titleView = headerLabel
        }
        else
        {
            self.navigationItem.title = title
        }
        self.ldSetNavigationBar(leftIcon: leftIcon, leftAction: leftAction, rightIcon: rightIcon, rightAction: rightAction)
    }
    
    
    /// Set navigation bar header image and navigation bar button items
    ///
    /// - Parameters:
    ///   - backgroundColor: Navigation bar background color
    ///   - headerImage: Navigation bar header image
    ///   - leftIcon: Left icon image for the navigaton bar
    ///   - leftAction: Left action for the navigaton bar
    ///   - rightIcon: Right icon image for the navigaton bar
    ///   - rightAction: Right action for the navigaton bar
    open func ldSetNavigationBar(backgroundColor:UIColor? = nil, headerImage:UIImage? = nil, leftIcon:UIImage? = nil, leftAction:Selector? = nil, rightIcon:UIImage? = nil, rightAction:Selector? = nil)
    {
        self.ldSetNavigationbarBackgroundColor(backgroundColor: backgroundColor)
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        if let headerImage = headerImage
        {
            let headerIV = UIImageView(image: headerImage)
            self.navigationItem.titleView = headerIV
        }
        self.ldSetNavigationBar(leftIcon: leftIcon, leftAction: leftAction, rightIcon: rightIcon, rightAction: rightAction)
    }
    
    
    /// Set search bar inside navigation bar and navigation bar button items
    ///
    /// - Parameters:
    ///   - backgroundColor: Navigation bar background color
    ///   - searchBar: Search bar which should be places inside navigation bar
    ///   - leftIcon: Left icon image for the navigaton bar
    ///   - leftAction: Left action for the navigaton bar
    ///   - rightIcon: Right icon image for the navigaton bar
    ///   - rightAction: Right action for the navigaton bar
    open func ldSetNavigationBar(backgroundColor:UIColor? = nil, searchBar:UISearchBar, leftIcon:UIImage? = nil, leftAction:Selector? = nil, rightIcon:UIImage? = nil, rightAction:Selector? = nil)
    {
        self.ldSetNavigationbarBackgroundColor(backgroundColor: backgroundColor)
        if #available(iOS 11.0, *) {
            if let navigationBarHeight = self.navigationController?.navigationBar.frame.height
            {
                searchBar.heightAnchor.constraint(equalToConstant: navigationBarHeight).isActive = true
            }
        }
        self.navigationItem.titleView = searchBar
        self.ldSetNavigationBar(leftIcon: leftIcon, leftAction: leftAction, rightIcon: rightIcon, rightAction: rightAction)
    }
    
    
    // MARK: - Handle keyboard events
    
    /// Struct with associated keys for attaching handles as attributes to UIViewController inside extension
    private struct AssociatedKeys {
        
        /// Associated key string for handler which handles event when keyboard will appear
        static var AppearHandler = "AppearHandler"
        
        /// Associated key string for handler which handles event when keyboard will disappear
        static var HideHandler = "HideHandler"
    }
    
    
    /// Handler which handles event when keyboard will appear
    private var appearHandler : CompletionTwoNumbersHandler {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.AppearHandler) as? CompletionTwoNumbersHandler
            {
                return value
            }
            return { _,_ in }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.AppearHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Handler which handles event when keyboard will disappear
    private var hideHandler : EmptyCompletionHandler {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.HideHandler) as? EmptyCompletionHandler
            {
                return value
            }
            return {  }
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.HideHandler, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    /// Allows you to close the keyboard on a tap anywhere within the controller.
    open func ldHideKeyboardWhenTappedAround()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.ldDismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    /// Close the keyboard
    @objc open func ldDismissKeyboard()
    {
        view.endEditing(true)
    }
    
    /// Change constraints constant based on keyboard size or based on calculated value
    ///
    /// - Parameters:
    ///   - constraints: Array of constraint which contant value should be changed animated if it is required to avoid keyboard appearing above a text field or text view. Constraints should be set to move a view in right direction when keyboard appears or dissapears (for example, if a view should be pushed up when keyboard appears, increasing constraints constant should support moving that view up, and vice versa)
    ///   - changeConstraintConstantExactlyBasedOnMoveValue: Boolean value which indicates if
    ///   - additionalOffset: Additional offset if we don't want a keyboard to be sticked to a text field or to a text view
    open func ldChangeConstraintsConstantBasedOnKeyboardAnimatingPosition(constraints:NSLayoutConstraint..., changeConstraintConstantExactlyBasedOnMoveValue:Bool = false, additionalOffset:CGFloat = 0.0)
    {
        self.ldSetKeyboardListener(onAppear: { moveValue, keyboardHeight in
            for constraint in constraints
            {
                constraint.constant = changeConstraintConstantExactlyBasedOnMoveValue ? moveValue + additionalOffset : keyboardHeight + additionalOffset
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }, onHide: {
            for constraint in constraints
            {
                constraint.constant = 0.0
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        })
    }
    
    
    /// Set keyboard listener in order to handle appearing and disappearing keyboard
    ///
    /// - Parameters:
    ///   - onAppear: Handler for handling event when keyboard will appear
    ///   - onHide: Handler for handling event when keyboard will disappear
    open func ldSetKeyboardListener(onAppear:@escaping CompletionTwoNumbersHandler, onHide:@escaping EmptyCompletionHandler)
    {
        self.appearHandler = onAppear
        self.hideHandler = onHide
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    /// Handdle event when keyboard will appear
    ///
    /// - Parameter notification: Notification which has some information about keyboard, for example keyboard size
    @objc private func keyboardWillAppear(_ notification:NSNotification) {
        //Do something here
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if let firstResponder = UIView.ldFindFirstResponder(inView: self.view)
            {
                if let firstResponderSuperview = firstResponder.superview
                {
                    let firstResponderBottom = firstResponderSuperview.convert(firstResponder.frame.origin, to: self.view).y + firstResponder.frame.size.height
                    
                    let move = firstResponderBottom + keyboardHeight < self.view.frame.size.height ? 0.0 : firstResponderBottom + keyboardHeight - self.view.frame.size.height
                    self.appearHandler(move, keyboardHeight)
                }
            }
        }
    }
    
    /// Handdle event when keyboard will disappear
    @objc private func keyboardWillDisappear() {
        //Do something here
        hideHandler()
    }
}

