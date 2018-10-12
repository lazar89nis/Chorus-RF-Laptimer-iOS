//
//  SplashVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 10/28/17.
//  Copyright © 2017 Lazar. All rights reserved.
//

import UIKit
import LDMainFramework

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        LDUtility.ldDelay(2)
        {
            let storyboard = UIStoryboard(name: StoryboardId.mainStoryboard, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: ViewControllerId.navController)
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            
            self.present(vc, animated: true, completion: nil)
        }
    }
}
