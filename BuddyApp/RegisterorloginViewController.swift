//
//  RegisterorloginViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class RegisterorloginViewController: UIViewController {
    
    @IBOutlet weak var registr_btn: UIButton!
    @IBOutlet weak var login_btn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
       
        
        login_btn.layer.cornerRadius = 5
        login_btn.layer.borderColor = UIColor.darkGray.cgColor
        login_btn.layer.borderWidth = 2
        login_btn.clipsToBounds = true
        
         registr_btn.layer.cornerRadius = 5
        registr_btn.clipsToBounds = true
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let controller = segue.destination as! RegisterChoiceViewController

        if segue.identifier == "register" {
            
            
            controller.choice = "register"
            
        }
        else{
            controller.choice = "login"
        }

        
        
    }
 

}
