//
//  SplashVC.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 10/28/17.
//  Copyright © 2017 Hypercube. All rights reserved.
//

import UIKit
import HCFramework

class SplashVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        HCUtility.hcDelay(2)
        {
            let storyboard = UIStoryboard(name: StoryboardId.mainStoryboard, bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: ViewControllerId.navController)
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            vc.modalPresentationStyle = .fullScreen

            self.present(vc, animated: true, completion: nil)
        }
    }
}
