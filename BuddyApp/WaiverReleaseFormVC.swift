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
    func waiverReleaseFormSubmitted(parentName: String, isAccepted: Bool)
}

class WaiverReleaseFormVC: UIViewController {

    @IBOutlet weak var lblDescription: TTTAttributedLabel!
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var txtParentsName: UITextField!
    
    var isAgeUnder18 = Bool()
    
    var isAcceptedWaiverRelease = Bool()
    weak var delegateWRForm: WaiverReleaseFormSubmittedDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        txtParentsName.isUserInteractionEnabled = false

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let str : NSString = PLEASE_ACCEPT_WAIVER_RELEASE_FORM_LABEL as NSString
        lblDescription.delegate = self
        lblDescription.text = str as String
        let waiver_release : NSRange = str.range(of: WAIVER_RELEASE)
        lblDescription.addLink(to: NSURL(string: WAIVER_RELEASE_URL)! as URL!, with: waiver_release)
    }
    
    @IBAction func checkBoxAction(_ sender: Any) {
        
        if isAgeUnder18{
            isAgeUnder18 = false
            btnCheckBox.setImage(#imageLiteral(resourceName: "TandCUnchecked"), for: .normal)
            txtParentsName.isUserInteractionEnabled = false
        }else{
            isAgeUnder18 = true
            btnCheckBox.setImage(#imageLiteral(resourceName: "TandCChecked"), for: .normal)
            txtParentsName.isUserInteractionEnabled = true
        }
    }

    @IBAction func acceptAction(_ sender: Any) {
        
        if isAgeUnder18 && txtParentsName.text == "" {
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: "Please enter parents name", buttonTitle: "OK")
        }else{
            
            delegateWRForm?.waiverReleaseFormSubmitted(parentName: txtParentsName.text!,isAccepted: true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func denyAction(_ sender: Any) {
        
        delegateWRForm?.waiverReleaseFormSubmitted(parentName: "",isAccepted: false)
        dismiss(animated: true, completion: nil)
    }
}

extension WaiverReleaseFormVC: TTTAttributedLabelDelegate {
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.open(url)
    }
}

