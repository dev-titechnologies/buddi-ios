//
//  LeftViewController.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class LeftViewController: UIViewController {
    @IBOutlet weak var profileimage: UIImageView!
    
    var imageArray = Array<ProfileImageDB>()

    let leftMenuArray = ["Home","Payment","History","Notifications","Settings","Booking","Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imagearray = ProfileImageDB.fetchImage() {
            self.imageArray = imagearray as! Array<ProfileImageDB>
            
            let obj = self.imageArray[0].value(forKey: "imageData")
           // print("DBBB",obj!)
            
            profileimage.image = UIImage(data: obj as! Data)

            
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

extension LeftViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leftMenuArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: LeftMenuTableCell = tableView.dequeueReusableCell(withIdentifier: "leftMenuCellId") as! LeftMenuTableCell
        
        cell.lblLeftMenuTitle.text = leftMenuArray[indexPath.row]
        
        return cell

    }
}

extension LeftViewController : UITableViewDelegate{
    
}
