//
//  SubCategorySelectionVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SubCategorySelectionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        
        CommonMethods.serverCall(APIURL: "category/listCategory", parameters: [:], headers: nil, onCompletion: { (jsondata) in
            
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: "Error", message: "Server not responding", buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == 1{
                    print("okkkk")
                }
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
