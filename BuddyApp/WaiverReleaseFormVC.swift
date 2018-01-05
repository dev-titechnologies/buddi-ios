//
//  WaiverReleaseFormVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 02/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import UIKit
import TTTAttributedLabel

protocol WaiverReleaseFormSubmittedDelegate: class {
    func waiverReleaseFormSubmitted(participantSign: String,parentSign: String, isAccepted: Bool)
}

class WaiverReleaseFormVC: UIViewController {
    
    var isAgeUnder18 = Bool()
    
    var isAcceptedWaiverRelease = Bool()
    weak var delegateWRForm: WaiverReleaseFormSubmittedDelegate?

    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnDeny: UIButton!
    @IBOutlet weak var firstWebview: UIWebView!
    @IBOutlet weak var secondWebview: UIWebView!
    @IBOutlet weak var parentSignatureView: UIView!
    @IBOutlet weak var parentSignatureHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblParticipantDate: UILabel!
    @IBOutlet weak var lblParentsDate: UILabel!
    @IBOutlet weak var txtParticipant: UITextField!
    @IBOutlet weak var txtParent: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        btnAccept.addShadowView()
        btnDeny.addShadowView()
        
        if let age = userDefaults.value(forKey: "traineeAge") as? String{
            print("Age:\(String(describing: userDefaults.value(forKey: "traineeAge") as? String))")
            if Int(age)! > 18 {
                hideSecondViewIfMinor()
                isAgeUnder18 = false
            }else{
                isAgeUnder18 = true
            }
        }
        
        loadHTMLContentToWebView(htmlPageName: "FirstPart", webView: firstWebview)
        loadHTMLContentToWebView(htmlPageName: "SecondPart", webView: secondWebview)
        
        lblParentsDate.text = currentDate()
        lblParticipantDate.text = currentDate()
    }
    
    func currentDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yyyy"
        let result = formatter.string(from: date)
        return result
    }
    
    func hideSecondViewIfMinor(){
        lblParentsDate.isHidden = true
        txtParent.isHidden = true
        parentSignatureHeightConstraint.constant = 0
        secondViewHeightConstraint.constant = 0
    }
    
    func loadHTMLContentToWebView(htmlPageName: String, webView: UIWebView){
        do {
            guard let filePath = Bundle.main.path(forResource: htmlPageName, ofType: "html")
                else {
                    print ("File reading error")
                    return
            }
            
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            print("CONTENTS:\(contents)")
            let baseUrl = URL(fileURLWithPath: filePath)
            webView.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        
        print("participantSign:\(txtParticipant.text!)")
        print("parentSign:\(txtParent.text!)")

        if isAgeUnder18 && txtParticipant.text == "" && txtParent.text == ""{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter signature", buttonTitle: "OK")
        }else if !isAgeUnder18 && txtParticipant.text == ""{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter signature", buttonTitle: "OK")
        }else if isAgeUnder18 {
            delegateWRForm?.waiverReleaseFormSubmitted(participantSign: txtParticipant.text!, parentSign: txtParent.text!, isAccepted: true)
            dismiss(animated: true, completion: nil)
        }else if !isAgeUnder18 {
            delegateWRForm?.waiverReleaseFormSubmitted(participantSign: txtParticipant.text!, parentSign: "", isAccepted: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func denyAction(_ sender: Any) {
        
        delegateWRForm?.waiverReleaseFormSubmitted(participantSign: "", parentSign: "", isAccepted: false)
        dismiss(animated: true, completion: nil)
    }
}



