//
//  LegalPageVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class LegalPageVC: UIViewController {

    let legalTableCaptionsArray = [TERMS_OF_USE_LINK_DISPLAY_TEXT, PRIVACY_POLICY_LINK_DISPLAY_TEXT, DISCLAIMER_LINK_DISPLAY_TEXT]
    let cellReuseIdentifier = "cellidentifier"
    var timer = Timer()
    
    @IBOutlet weak var legalTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Legal Page viewDidLoad")
        self.title = PAGE_TITLE.LEGAL
        
       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension LegalPageVC : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legalTableCaptionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell!
        
        cell.textLabel?.text = legalTableCaptionsArray[indexPath.row]

        return cell
    }
}

extension LegalPageVC : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            //Terms of Use
            openUrlInWebPage(url: URL(string: TERMS_OF_USE_URL)!)
            
        }else if indexPath.row == 1 {
            //Privacy Policy
            openUrlInWebPage(url: URL(string: PRIVACY_POLICY_URL)!)
            
        }else if indexPath.row == 2 {
            //Disclaimer
            openUrlInWebPage(url: URL(string: DISCLAIMER_URL)!)
        }
    }
    
    func openUrlInWebPage(url: URL) {
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
