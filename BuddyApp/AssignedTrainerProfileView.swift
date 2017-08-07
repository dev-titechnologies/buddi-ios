//
//  AssignedTrainerProfileView.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 04/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class AssignedTrainerProfileView: UIViewController {

    @IBOutlet weak var imgProfileImage: UIImageView!
    
    @IBOutlet weak var lblProfileName: UILabel!
    @IBOutlet weak var lblTrainerAge: UILabel!
    @IBOutlet weak var lblTrainerHeight: UILabel!
    @IBOutlet weak var lblTrainerWeight: UILabel!
    @IBOutlet weak var lblMeetingDescription: UILabel!
    @IBOutlet weak var trainerDescriptionTable: UITableView!
    
    var assignedTrainerProfileView = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        assignedTrainerProfileView = ["Gym Subscriptions", "Training Category", "Training History", "Coaching History", "Certifications"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension AssignedTrainerProfileView: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignedTrainerProfileView.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
            let cell: AssignedTrainerProfileTableCaptionsCell = tableView.dequeueReusableCell(withIdentifier: "captionCellId") as! AssignedTrainerProfileTableCaptionsCell
            
            
            return cell

        }else if indexPath.row == 5{
            let cell: AssignedTrainerSocialMediaCell = tableView.dequeueReusableCell(withIdentifier: "socialMediaCellId") as! AssignedTrainerSocialMediaCell
            return cell

        }else{
            let cell: AssignedTrainerEmailCell = tableView.dequeueReusableCell(withIdentifier: "emailCellId") as! AssignedTrainerEmailCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        var row = 0.0
        
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 {
           row = 60.0
        }else if indexPath.row == 5{
            row = 150.0
        }else{
            row = 60.0
        }
        return CGFloat(row)
    }
}

extension AssignedTrainerProfileView: UITableViewDelegate{
    
}
