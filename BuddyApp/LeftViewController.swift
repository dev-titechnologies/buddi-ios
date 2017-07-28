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
    var objdata = NSData()

    let leftMenuArrayTrainer = ["Home","Settings","Payment Method","Training History","Invite Friends","Help","Legal","Logout"]
    
    let leftMenuArrayTrainee = ["Home","Settings","Payment Method","Become a Trainer","Training History","Invite Friends","Help","Legal","Logout"]

    
     let ImageArrayTrainer = ["HOME","SETTINGES","PAY","TRAINING-HISTORY","FRIENDS","HELP","LEGAL","LOGOUT"]
    
    let ImageArrayTrainee = ["HOME","SETTINGES","PAY","BECOME-TRAINER","TRAINING-HISTORY","FRIENDS","HELP","LEGAL","LOGOUT"]
    
   // let ImageArray = ["HOME","PAY","TRAINING-HISTORY","LEGAL","SETTINGES","HELP","LOGOUT"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let imagearray = ProfileImageDB.fetchImage() {
//            self.imageArray = imagearray as! Array<ProfileImageDB>
//            
//            let obj = self.imageArray[0].value(forKey: "imageData")
//           // print("DBBB",obj!)
//            
//            profileimage.image = UIImage(data: obj as! Data)
//
//            
//        }
//        
        
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            if let imagearray = ProfileImageDB.fetchImage() {
                self.imageArray = imagearray as! Array<ProfileImageDB>
                
                 self.objdata = self.imageArray[0].value(forKey: "imageData") as! NSData
                // print("DBBB",obj!)
                
                
                
                
            }
            DispatchQueue.main.async {
                print("This is run on the main queue, after the previous code in outer block")
                
                self.profileimage.image = UIImage(data: self.objdata as Data)
            }
        }
        
        

    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}

extension LeftViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if appDelegate.USER_TYPE == "trainer"
        {
            return leftMenuArrayTrainer.count
        }
        else
        {
            return leftMenuArrayTrainee.count
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: LeftMenuTableCell = tableView.dequeueReusableCell(withIdentifier: "leftMenuCellId") as! LeftMenuTableCell
        
        if appDelegate.USER_TYPE == "trainer"
        {
            
            cell.lblLeftMenuTitle.text = leftMenuArrayTrainer[indexPath.row]
            
            cell.icon_img.image = UIImage(named: ImageArrayTrainer[indexPath.row])

        }
        else
        {
            
            cell.lblLeftMenuTitle.text = leftMenuArrayTrainee[indexPath.row]
            
            cell.icon_img.image = UIImage(named: ImageArrayTrainee[indexPath.row])

        }

        
        
        
        
        return cell

    }
    }

extension LeftViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        if appDelegate.USER_TYPE == "trainer"
        {
            
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
                 self.performSegue(withIdentifier: "history", sender:self)
                
            case 4:
                print("four")
               
                
                
            case 5:
                print("five")
                
            case 6:
                print("six")
                
            case 7:
                print("seven")
                
            dismissOnSessionExpire()
                
            default:
                print("Integer out of range")
            }
            

        }
        else
        {
            
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
                
                self.performSegue(withIdentifier: "fromlefttocatgory", sender: self)
                
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
    

}
