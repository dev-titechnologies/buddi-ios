//
//  LoginViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 18/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController,GIDSignInUIDelegate{

    @IBOutlet weak var FB_btn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        GIDSignIn.sharedInstance().signOut()
        // Do any additional setup after loading the view.
//        GIDSignIn.sharedInstance().uiDelegate = self as! GIDSignInUIDelegate

        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GoogleLogin_action(_ sender: Any) {
        
         GIDSignIn.sharedInstance().signIn()
        
    }
    
    //MARK:Google SignIn Delegate
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    // Present a view that prompts the user to sign in with Google
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    // Dismiss the "Sign in with Google" view
    
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    //completed sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        
        
        if (error == nil)
        {
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let name = user.profile.name
            let email = user.profile.email
            //let userImageURL = user.profile.imageURLWithDimension(200)
            // ...
            
            
            //print(user)
            print(userId!)
            print(idToken!)
            print(name!)
            print(email!)
        }
        else
        {
            print("\(error.localizedDescription)")
        }
        
        
    }
    

    
    
    @IBAction func FaceBookLogin_Action(_ sender: Any) {
        
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                
                if (result?.isCancelled)! {
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }

        
        
    }
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    print("RESULT",result!)
                    
                }
            })
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
