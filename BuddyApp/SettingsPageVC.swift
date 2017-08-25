//
//  SettingsPageVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 24/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SettingsPageVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var settingsTableView: UITableView!
    let headerSectionTitles = ["Location Preference" ,"Training Category Preference", "Gender Preference", "Session Length Preference"]
    var collapseArray = [Bool]()
    var sessionChoosed = Int()
    var headerChoosed = Int()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.SETTINGS
        
        sessionChoosed = -1
        headerChoosed = -1

        for _ in 0..<headerSectionTitles.count{
            collapseArray.append(false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SettingsPageVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return headerSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 2{
            return 1
        }else if section == 3{
            return 2
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 3{
            //Preferred Session
            let sessionCell: SessionPreferenceCell = tableView.dequeueReusableCell(withIdentifier: "chooseSessionCellId") as! SessionPreferenceCell
            
            sessionCell.lblSessionDuration.text = trainingDurationArray[indexPath.row]
            
            if sessionChoosed == indexPath.row{
                sessionCell.backgroundCardView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                sessionCell.backgroundCardView.backgroundColor = .white
            }
            
            return sessionCell
        }else if indexPath.section == 2{
            //Preferred Gender
            
            let genderCell: GenderPreferenceCell = tableView.dequeueReusableCell(withIdentifier: "chooseGenderCellId") as! GenderPreferenceCell
            
            genderCell.selectionStyle = UITableViewCellSelectionStyle.none
            
            genderCell.btnMale.addShadowView()
            genderCell.btnFemale.addShadowView()
            genderCell.btnNopreferance.addShadowView()
            
            return genderCell
        }else{
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cellid")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if collapseArray[indexPath.section]{
            if indexPath.section == 3{
                return 60
            }else if indexPath.section == 2{
                return 114
            }else{
                return 0
            }
        }else{
            return 0
        }
    }
    
    //MARK: - TABLEVIEW HEADER SECTION VIEW
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell: PreferenceSectionHeader = tableView.dequeueReusableCell(withIdentifier: "sectionHeaderCellId") as! PreferenceSectionHeader
        
        cell.lblHeaderSectionTitle.text = headerSectionTitles[section]
        
        if headerChoosed == -1{
            print("Init")
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }else if collapseArray[headerChoosed] {
            cell.imgArrow.image = UIImage(named: "downArrow")
        }else{
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.didTapSectionHeader(_:)))
        cell.contentView.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.view?.tag = section
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        sessionChoosed = indexPath.row
        settingsTableView.reloadSections(IndexSet(integer: 3), with: .automatic)
        
        if indexPath.section == 3{
            if indexPath.row == 0 {
                choosedSessionOfTrainee = "40"
            }else{
                choosedSessionOfTrainee = "60"
            }
        }
        print("Choosed Session:\(choosedSessionOfTrainee)")
    }
    
    func didTapSectionHeader(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        
        let indexpath: IndexPath = IndexPath.init(row: 0, section: (sender.view?.tag)!)
        print("Tapped Index:",indexpath.section)
        
        headerChoosed = (sender.view?.tag)!
        let collapsed = collapseArray[indexpath.section]
        if indexpath.section == 2 || indexpath.section == 3 {
            self.collapseArray[indexpath.section] = !collapsed
            self.settingsTableView.reloadSections(IndexSet(integer: sender.view!.tag), with: .automatic)
        }
    }
}

