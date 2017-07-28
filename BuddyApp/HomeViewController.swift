//
//  HomeViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        if CommonMethods.networkcheck() == true{
            
            print("internet available")
            
        }
        else{
            
            
            print("Please check internet connection")
        }
        
        

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
