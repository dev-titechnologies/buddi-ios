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
    
    override func viewWillAppear(_ animated: Bool) {
        
        let notificationName = Notification.Name("FCMNotificationIdentifier")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.triggerDismissWhenNotificationReceived), name: notificationName, object: nil)
        
        let when = DispatchTime.now() + 30
        DispatchQueue.main.asyncAfter(deadline: when) {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: TRAINING_REQUEST_REVOCKED, buttonTitle: "OK")
            self.dismissWaitingForAcceptancePage()
        }
    }
    
    func triggerDismissWhenNotificationReceived(notif: NSNotification) {
        
        if notif.userInfo!["type"] as! String == "1" {
            dismissWaitingForAcceptancePage()
        }
    }
    
    func dismissWaitingForAcceptancePage(){
        print("Dismiss Waiting for Acceptance Page while receiving notification")
        userDefaults.set(false, forKey: "isWaitingForTrainerAcceptance")
        
        let presentingViewController: UIViewController! = self.presentingViewController
        self.dismiss(animated: false) {
            presentingViewController.dismiss(animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
