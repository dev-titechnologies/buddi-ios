//
//  ChooseSessionAndGenderVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 03/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class ChooseSessionAndGenderVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var chooseSessionAndGenderTable: UITableView!
   
    let headerSectionTitles = ["Choose Session Duration" ,"Choose Trainer Gender"]
    var collapseArray = [Bool]()
    var sessionChoosed = Int()
    var headerChoosed = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sessionChoosed = -1
        headerChoosed = -1
        
        for _ in 0..<headerSectionTitles.count{
            collapseArray.append(false)
        }
    }
    
    @IBAction func nextButtonActions(_ sender: Any) {
        performSegue(withIdentifier: "afterChoosingSessionAndGenderSegue", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension ChooseSessionAndGenderVC: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0{
            return trainingDurationArray.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0{
            let sessionCell: ChooseSessionTableCell = tableView.dequeueReusableCell(withIdentifier: "chooseSessionCellId") as! ChooseSessionTableCell
            
            sessionCell.lblSessionDuration.text = trainingDurationArray[indexPath.row]
            
            if sessionChoosed == indexPath.row{
                sessionCell.backgroundCardView.backgroundColor = CommonMethods.hexStringToUIColor(hex: APP_BLUE_COLOR)
            }else{
                sessionCell.backgroundCardView.backgroundColor = .white
            }
            
            return sessionCell
        }else{
            let genderCell: ChooseGenderTableCell = tableView.dequeueReusableCell(withIdentifier: "chooseGenderCellId") as! ChooseGenderTableCell
            
            genderCell.btnMale.addShadowView()
            genderCell.btnFemale.addShadowView()
            
            return genderCell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let cell: SectionHeaderCell = tableView.dequeueReusableCell(withIdentifier: "sectionHeaderCellId") as! SectionHeaderCell
        
        cell.lblHeaderSectionTitle.text = headerSectionTitles[section]
        
        if headerChoosed == -1{
            print("Init")
            cell.imgArrow.image = UIImage(named: "rightArrow")
        }else if collapseArray[headerChoosed]{
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
    
    func didTapSectionHeader(_ sender: UITapGestureRecognizer) {
        print("Please Help!")
        
        let indexpath: IndexPath = IndexPath.init(row: 0, section: (sender.view?.tag)!)
        print("Tapped Index:",indexpath.section)
        
        headerChoosed = (sender.view?.tag)!
        let collapsed = collapseArray[indexpath.section]
        collapseArray[indexpath.section] = !collapsed
        self.chooseSessionAndGenderTable.reloadSections(IndexSet(integer: sender.view!.tag), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if collapseArray[indexPath.section]{
            return 60
        }else{
            return 0
        }
    }
}

extension ChooseSessionAndGenderVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        sessionChoosed = indexPath.row
        chooseSessionAndGenderTable.reloadSections(IndexSet(integer: 0), with: .automatic)
        choosedSessionOfTrainee = trainingDurationArray[indexPath.row]
        print("Choosed Session:\(choosedSessionOfTrainee)")
    }
}



