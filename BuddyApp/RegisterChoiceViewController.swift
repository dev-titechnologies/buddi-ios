//
//  RegisterChoiceViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class RegisterChoiceViewController: UIViewController {
 var choice = String()
    @IBOutlet weak var Trainer_btn: UIButton!
    @IBOutlet weak var User_btn: UIButton!
    
    var usertype = String()
    override func viewDidLoad() {
        super.viewDidLoad()

        
       
        
        
        // Do any additional setup after loading the view.
        Trainer_btn.layer.borderColor = UIColor.darkGray.cgColor
        Trainer_btn.layer.borderWidth = 2
        Trainer_btn.clipsToBounds = true
        
        User_btn.layer.borderColor = UIColor.darkGray.cgColor
        User_btn.layer.borderWidth = 2
        User_btn.clipsToBounds = true

        
        if choice == "register"
        {
            Trainer_btn.setTitle("REGISTER AS A TRAINER",for: .normal)
            User_btn.setTitle("REGISTER AS A USER",for: .normal)
            
         
        }
        else{
            
            Trainer_btn.setTitle("LOGIN AS A TRAINER",for: .normal)
            User_btn.setTitle("LOGIN AS A USER",for: .normal)
            
            }
        
        
        
        
        
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
    @IBAction func User_action(_ sender: Any) {
        
        usertype = "trainee"
        
        if choice == "register"
        {
             self.performSegue(withIdentifier: "toregister", sender: self)
            
        }
        else{
             self.performSegue(withIdentifier: "tologin", sender: self)
        }
        
        
        
        
    }
    
    @IBAction func Trainer_action(_ sender: Any) {
        
        usertype = "trainer"
        
        if choice == "register"
        {
            self.performSegue(withIdentifier: "toregister", sender: self)
            
        }
        else{
            self.performSegue(withIdentifier: "tologin", sender: self)
        }
        

    }

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        
        if segue.identifier == "toregister" {
            
            let controller = segue.destination as! RegisterViewController
            controller.UserType = usertype
            
        }
        else{
            let controller = segue.destination as! LoginViewController
            controller.UserType = usertype
        }
        

        
        
        
    }
    

}
