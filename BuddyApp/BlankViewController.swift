//
//  BlankViewController.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 31/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class BlankViewController: UIViewController {

    @IBOutlet weak var blankText: UILabel!
    var blankTextValue = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        blankText.text = blankTextValue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
