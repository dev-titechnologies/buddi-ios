//
//  HelpPageVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 21/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class HelpPageVC: UIViewController {

    @IBOutlet weak var contactemail: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.HELP
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
