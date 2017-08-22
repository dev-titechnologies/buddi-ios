//
//  LegalPageVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class LegalPageVC: UIViewController {

    let legalTableCaptionsArray = ["Copyright", "Terms & Conditions", "Privacy Policy", "Using Your Location"]
    let cellReuseIdentifier = "cellidentifier"
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
    
}
