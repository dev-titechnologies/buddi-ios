//
//  AcceptOrDeclineRequestPage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 30/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class AcceptOrDeclineRequestPage: UIViewController {

    @IBOutlet weak var lblRequestDescription: UILabel!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDecline: UIButton!
    
     var ProfileDictionary: NSMutableDictionary!
     var TrainerProfileDictionary: NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view?.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        
     ProfileDictionary = userDefaults.object(forKey: "TrainerProfileDictionary") as! NSDictionary as! NSMutableDictionary

    }
    
    override func viewWillAppear(_ animated: Bool) {
        btnAccept.addShadowView()
        btnDecline.addShadowView()
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        self.Booking_API(URL: ACCEPT_BOOKING, acceptstatus: true)
    }
    
    @IBAction func declineAction(_ sender: Any) {
        self.Booking_API(URL: DECLINE_BOOKING, acceptstatus: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func Booking_API(URL: String, acceptstatus: Bool){
        
        print(ProfileDictionary)
        var parameters = ["trainer_id":appDelegate.UserId,
                          "trainee_id":ProfileDictionary["trainee_id"]!,
                          "gender":ProfileDictionary["gender"]!,
                          "training_time": ProfileDictionary["training_time"]!,
                          "category_id": ProfileDictionary["category_id"]!,
                          "latitude": ProfileDictionary["latitude"]! ,
                          "longitude": ProfileDictionary["longitude"]!
            ]
            as [String : Any]
        
        let headers = [
            "token": appDelegate.Usertoken
                ]
        
        if (ProfileDictionary["transaction_id"] as? String) != nil{
            let transactionDict = ["transaction_id" : ProfileDictionary["transaction_id"]!,
                                   "amount" : ProfileDictionary["amount"]!,
                                   "transaction_status" : ProfileDictionary["transaction_status"]!
                ] as [String : Any]
            
            parameters = parameters.merged(with: transactionDict as! Dictionary<String, String>)
        }else{
            parameters = parameters.merged(with: ["promocode" : "TEST CODE"])
        }
 
        print("Params:",parameters)
        print("Header:",headers)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: URL, parameters: parameters, headers: headers , onCompletion: { (jsondata) in
            print("BOOKING RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    //self.dismiss(animated: true, completion: nil)
                    
                    if acceptstatus{
                        if (jsondata["data"] as? NSDictionary) != nil {
                            
                            self.TrainerProfileDictionary = jsondata["data"] as? NSDictionary
                        }
                      // fromAcceptToTimer
                        self.performSegue(withIdentifier: "fromAcceptToTimer", sender: self)
                        
                    }else{
                        
                    }
                }else if status == RESPONSE_STATUS.FAIL{

                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }else{
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: REQUEST_TIMED_OUT, buttonTitle: "OK")
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "fromAcceptToTimer" {
            let timerPage =  segue.destination as! TrainerTraineeRouteViewController
           
                timerPage.TrainerProfileDictionary = self.TrainerProfileDictionary
                timerPage.seconds = Int(self.TrainerProfileDictionary["training_time"] as! String)!*60
                print("SECONDSSSS",timerPage.seconds)
        }
    }
}
