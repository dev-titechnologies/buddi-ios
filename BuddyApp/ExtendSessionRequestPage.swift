//
//  ExtendSessionRequestPage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 13/09/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ExtendSessionRequestPage: UIViewController {

    @IBOutlet weak var btnYesExtend: UIButton!
    @IBOutlet weak var btnNoExtend: UIButton!
    @IBOutlet weak var btnSession40Minutes: UIButton!
    @IBOutlet weak var btnSession1Hour: UIButton!
    
    @IBOutlet weak var extendAlertView: CardView!
    @IBOutlet weak var sessionAlertView: CardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func extendYesAction(_ sender: Any) {
    }
    @IBAction func extendNoAction(_ sender: Any) {
    }
    @IBAction func session40MinutesAction(_ sender: Any) {
    }
    @IBAction func session1HourAction(_ sender: Any) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
