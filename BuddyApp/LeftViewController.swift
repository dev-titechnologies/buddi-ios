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

    let leftMenuArray = ["Home","Settings","Payment Method","Become a Trainer","Training History","Invit Friends","Help","Legal","Logout"]
    
     let ImageArray = ["HOME","SETTINGES","PAY","BECOME-TRAINER","TRAINING-HISTORY","FRIENDS","HELP","LEGAL","LOGOUT"]
    
   // let ImageArray = ["HOME","PAY","TRAINING-HISTORY","LEGAL","SETTINGES","HELP","LOGOUT"]
    
    
    
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
        
        cell.icon_img.image = UIImage(named: ImageArray[indexPath.row])
        
        return cell

    }
    }

extension LeftViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        switch (indexPath.row)
        {
        case 0:
            print("zero")
            
        case 1:
            print("one")
            
        case 2:
            print("two")
            
        case 3:
            print("three")
            
        case 4:
            print("four")
            self.performSegue(withIdentifier: "history", sender:self)
            
            
        case 5:
            print("five")
            
        case 6:
            print("six")
            
        case 7:
            print("seven")
            
        case 8:
            print("eight")
            
            dismissOnSessionExpire()
            
        default:
            print("Integer out of range")
        }
        
    }
    

}
