//
//  WaitingForAcceptancePage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 06/09/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class WaitingForAcceptancePage: UIViewController {

    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicatorView.startAnimating()
        activityIndicatorView.type = .ballScaleMultiple
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
