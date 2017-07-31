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
    @IBOutlet weak var leftMenuTableview: UITableView!
    
    var imageArray = Array<ProfileImageDB>()
    var objdata = NSData()
    var leftMenuArrayTraineeCopy = [String]()
    var isTraineeAlreadyTrainer = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let isTraineeAlreadyTrainerHasValue = userDefaults.value(forKey: "ifAlreadyTrainer") as? Bool {
            isTraineeAlreadyTrainer = isTraineeAlreadyTrainerHasValue
        }
        
        if isTraineeAlreadyTrainer {
            leftMenuArrayTraineeCopy = leftMenuTraineeAndTrainerAlso
        }else{
            leftMenuArrayTraineeCopy = leftMenuTrainee
        }
        
        DispatchQueue.global(qos: .background).async {
            print("This is run on the background queue")
            
            if let imagearray = ProfileImageDB.fetchImage() {
                self.imageArray = imagearray as! Array<ProfileImageDB>
                
                guard self.imageArray.count > 0 else{
                    return
                }
                self.objdata = self.imageArray[0].value(forKey: "imageData") as! NSData
                DispatchQueue.main.async {
                    print("This is run on the main queue, after the previous code in outer block")
                    self.profileimage.image = UIImage(data: self.objdata as Data)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "blankPageSegue" {
            let path = leftMenuTableview.indexPathForSelectedRow!

            let blankPage =  segue.destination as! BlankViewController
            if appDelegate.USER_TYPE == "trainer"{
                blankPage.blankTextValue = leftMenuTrainer[path.row]
            }else{
                if isTraineeAlreadyTrainer {
                    blankPage.blankTextValue = leftMenuTraineeAndTrainerAlso[path.row]
                }else{
                    blankPage.blankTextValue = leftMenuTrainee[path.row]
                }
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
        
        if appDelegate.USER_TYPE == "trainer"{
            return leftMenuTrainer.count
        }else{
            return leftMenuArrayTraineeCopy.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: LeftMenuTableCell = tableView.dequeueReusableCell(withIdentifier: "leftMenuCellId") as! LeftMenuTableCell
        
        if appDelegate.USER_TYPE == "trainer" {
            //For Trainer
            cell.lblLeftMenuTitle.text = leftMenuTrainer[indexPath.row]
            cell.icon_img.image = UIImage(named: ImageArrayTrainer[indexPath.row])
        }else{
            //For Trainee
            if isTraineeAlreadyTrainer{
                cell.lblLeftMenuTitle.text = leftMenuTraineeAndTrainerAlso[indexPath.row]
                cell.icon_img.image = UIImage(named: ImageArrayTraineeAndTrainerAlso[indexPath.row])
            }else{
                cell.lblLeftMenuTitle.text = leftMenuArrayTraineeCopy[indexPath.row]
                cell.icon_img.image = UIImage(named: ImageArrayTrainee[indexPath.row])
            }
        }
        return cell
    }
}

extension LeftViewController : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if appDelegate.USER_TYPE == "trainer"{

            switch (indexPath.row) {
            case 0:
                print("zero")
                print("Home")
                self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                
            case 1:
                print("one")
                print("Settings")
                self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                
            case 2:
                print("two")
                print("Add Category")
                self.performSegue(withIdentifier: "fromlefttocatgory", sender: self)
                
            case 3:
                print("three")
                print("Training History")
//                 self.performSegue(withIdentifier: "history", sender:self)
                self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                
            case 4:
                print("four")
                print("Invite Friends")
                self.performSegue(withIdentifier: "blankPageSegue", sender: self)
               
            case 5:
                print("five")
                print("Help")
                self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                
            case 6:
                print("six")
                print("Legal")
                self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                
            case 7:
                print("seven")
                print("Logout")
                dismissOnSessionExpire()
                
            default:
                print("Integer out of range")
            }
        }else{
            //For Trainee
            
            switch (indexPath.row)
            {
            case 0:
                print("zero")
                print("Home")
                self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                
            case 1:
                print("one")
                print("Settings")
                self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                
            case 2:
                print("two")
                if isTraineeAlreadyTrainer{
                    //Already a Trainer
                    print("Payment Method")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)

                }else{
                    print("Become a Trainer")
                    self.performSegue(withIdentifier: "fromlefttocatgory", sender: self)
                }
                
            case 3:
                print("three")
                if isTraineeAlreadyTrainer{
                    print("Training History")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                }else{
                    print("Payment Method")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                }
                
            case 4:
                print("four")
                if isTraineeAlreadyTrainer{
                    print("Invite Friends")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                }else{
                    print("Training History")
//                    self.performSegue(withIdentifier: "history", sender:self)
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                }
                
            case 5:
                print("five")
                if isTraineeAlreadyTrainer{
                    print("Help")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                }else{
                    print("Invite Friends")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                }
                
            case 6:
                print("six")
                if isTraineeAlreadyTrainer{
                    print("Legal")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                }else{
                    print("Help")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)
                }

            case 7:
                print("seven")
                if isTraineeAlreadyTrainer{
                    print("Logout")
                    dismissOnSessionExpire()
                }else{
                    print("Legal")
                    self.performSegue(withIdentifier: "blankPageSegue", sender: self)

                }
                
            case 8:
                print("eight")
                if isTraineeAlreadyTrainer{
                    
                }else{
                    print("Logout")
                    dismissOnSessionExpire()
                }
                
            default:
                print("Integer out of range")
            }
        }
    }
}
