//
//  LDSocialNetworkURL.swift
//
//  Created by Lazar on 9/27/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit

// Note: Add LSApplicationQueriesSchemes for every social network in in plist file
public enum LDPageType
{
    case ldUndefined
    case ldFacebookProfile
    case ldFacebookGroup
    case ldFacebookImage
    case ldFacebookEvent
    case ldFacebookMessanger
    case ldTwitterProfile
    case ldTwitterStatus
    case ldInstagramProfile
    case ldInstagramImage
    case ldYoutubeVideo
}

open class LDSocialNetworkURL: NSObject {
    
    open var id:String = ""
    open var link:String = ""
    open var urlScheme:String = ""
    open var pageType:LDPageType = .ldUndefined
    
    public init(id:String, link:String, pageType:LDPageType)
    {
        self.id = id
        self.link = link
        self.pageType = pageType
        switch pageType
        {
        case .ldFacebookProfile:
            self.urlScheme = "fb://"
        case .ldFacebookGroup:
            self.urlScheme = "fb://"
        case .ldFacebookImage:
            self.urlScheme = "fb://"
        case .ldFacebookEvent:
            self.urlScheme = "fb://"
        case .ldFacebookMessanger:
            self.urlScheme = "fb://"
        case .ldTwitterProfile:
            self.urlScheme = "twitter://"
        case .ldTwitterStatus:
            self.urlScheme = "twitter://"
        case .ldInstagramProfile:
            self.urlScheme = "instagram://"
        case .ldInstagramImage:
            self.urlScheme = "instagram://"
        case .ldYoutubeVideo:
            self.urlScheme = "youtube://"
        default:
            self.urlScheme = ""
        }
    }
    
    
    /// Tests whether it's possible to open urlScheme in Native App
    ///
    /// - Returns: It's possible to open urlScheme
    open func installedNativeApp() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: urlScheme)!)
    }
    
    /// Creates appURL based on pagetype and id
    ///
    /// - Returns: AppURL based on pagetype and id
    open func appUrl() -> String
    {
        switch pageType
        {
        case .ldFacebookProfile:
            return "fb://profile/\(id)"
        case .ldFacebookGroup:
            return "fb://group?id=\(id)"
        case .ldFacebookImage:
            return "fb://photo?id=\(id)"
        case .ldFacebookEvent:
            return "fb://event?id=\(id)"
        case .ldFacebookMessanger:
            return "fb://messaging"
        case .ldTwitterProfile:
            return "twitter://user?screen_name=\(id)"
        case .ldTwitterStatus:
            return "twitter://status?id=\(id)"
        case .ldInstagramProfile:
            return "instagram://user?username=\(id)"
        case .ldInstagramImage:
            return "instagram://media?id=\(id)"
        case .ldYoutubeVideo:
            return "youtube://\(id)"
        default:
            return ""
        }
    }
    
    /// Open link in app if it is possible, or open it in browser
    open func open()
    {
        if self.installedNativeApp()
        {
            if UIApplication.shared.canOpenURL(URL(string: self.appUrl())!)
            {
                UIApplication.shared.openURL(URL(string: self.appUrl())!)
            }
        }
        else
        {
            if UIApplication.shared.canOpenURL(URL(string: self.link)!)
            {
                UIApplication.shared.openURL(URL(string: self.link)!)
            }
        }
        
    }
    
}

