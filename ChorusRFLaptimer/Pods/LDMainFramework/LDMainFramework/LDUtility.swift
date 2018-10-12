//
//  LDUtility.swift
//
//  Created by Lazar on 8/16/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit
import SafariServices

///  All functions are static so they are all globally available through LDUtility class.
open class LDUtility
{
    // MARK: - Delay functions.
    
    /// Delay some function and then execute it async after the timer runs out.
    ///
    /// - Parameters:
    ///   - seconds: Number of seconds for delay timer.
    ///   - closure: Function that needs to start when the timer runs out.
    open static func ldDelay(_ seconds:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    // MARK: - OpenURL
    
    /// Open URL in SFSafariViewController.
    ///
    /// - Parameter urlStr: Url string that you want to open.
    open static func ldOpenURL(_ urlStr: String)
    {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let url = URL(string: urlStr)!
            
            let svc = SFSafariViewController(url: url)
            topController.present(svc, animated: true)
        }
    }
}

