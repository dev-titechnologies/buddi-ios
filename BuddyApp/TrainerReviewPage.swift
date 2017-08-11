//
//  TrainerReviewPage.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 10/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Alamofire

class TrainerReviewPage: UIViewController {
    

    let reviewDict = TrainerReviewModel()
    
    @IBOutlet weak var imgTrainerImage: UIImageView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var txtReviewDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        parseTrainerDetails()
    }
    
    func parseTrainerDetails() {
        
        //imgTrainerImage.sd_setImage(with: URL(string: reviewDict.profileImage, placeholderImage: UIImage(named: "")))
        lblTrainerName.text = reviewDict.trainerName
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancelAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        
    }
    
}
