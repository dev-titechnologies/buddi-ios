//
//  FinalQuestionsVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 25/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class FinalQuestionsVC: UIViewController {
    @IBOutlet weak var btnNext: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        btnNext.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        performSegue(withIdentifier: "afterFinalQuestionsSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
