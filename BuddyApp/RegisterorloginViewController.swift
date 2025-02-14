//
//  RegisterorloginViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

class RegisterorloginViewController: UIViewController {
    
    @IBOutlet weak var pagecontrole: UIPageControl!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var registr_btn: UIButton!
    @IBOutlet weak var login_btn: UIButton!
    
    let imageNames = ["1","2","3"]

    override func viewDidLoad() {
        super.viewDidLoad()

        print("**** Register or Login ViewController ViewDidLoad ****")
        
        login_btn.layer.cornerRadius = 5
        login_btn.layer.borderColor = UIColor.darkGray.cgColor
        login_btn.layer.borderWidth = 2
        login_btn.clipsToBounds = true
        
        registr_btn.layer.cornerRadius = 5
        registr_btn.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollview.isPagingEnabled = true
        self.scrollview.delegate = self
        setupImageViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        
//        let instance = FIRInstanceID.instanceID()
//        _ = FIRInstanceID.delete(instance)
//        FIRInstanceID.instanceID().delete { (err:Error?) in
//            if err != nil{
//                print(err.debugDescription);
//            } else {
//                print("Token Deleted");
//                
//                if let token = FIRInstanceID.instanceID().token() {
//                    print("Token \(token) fetched");
//                } else {
//                    print("Unable to fetch token");
//                }
//                
//                FIRMessaging.messaging().disconnect()
//                FIRMessaging.messaging().connect { (error) in
//                    if (error != nil) {
//                        print("Error connecting to FCM. \(error.debugDescription)")
//                    } else {
//                        print("Connected to FCM.")
//                    }
//                }
//            }
//        }
        
        if userDefaults.value(forKey: "devicetoken") != nil{
            appDelegate.DeviceToken = userDefaults.value(forKey: "devicetoken") as! String
            print("TOKEN 1",appDelegate.DeviceToken)
        }else{
            print("************ DUMMY DEVICE TOKEN HAS BEEN INSERTED REG OR LOGIN PAGE ************")
            appDelegate.DeviceToken = "1234567890"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    func setupImageViews() {
        
        print("*** setupImageViews ***")
        var totalWidth: CGFloat = 0
        
        for imageName in imageNames {
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(origin: CGPoint(x: totalWidth, y: 0),
                                     size: scrollview.bounds.size)
            imageView.contentMode = .scaleAspectFit
            
            self.scrollview.addSubview(imageView)
            totalWidth += imageView.bounds.size.width
        }
        
        self.scrollview.contentSize = CGSize(width: totalWidth,
                                        height: scrollview.bounds.size.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let controller = segue.destination as! RegisterChoiceViewController

        if segue.identifier == "register" {
            controller.choice = "register"
        }else{
            controller.choice = "login"
        }
    }
}
extension RegisterorloginViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = Int(scrollView.contentSize.width) / self.imageNames.count
        pagecontrole.currentPage = Int(scrollView.contentOffset.x) / pageWidth
    }
}
