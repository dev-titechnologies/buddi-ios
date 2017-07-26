//
//  SubCategorySelectionVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SubCategorySelectionVC: UIViewController {

    @IBOutlet weak var btnYesLostOrGainWeight: UIButton!
    @IBOutlet weak var btnNoLostOrGainWeight: UIButton!

    @IBOutlet weak var subCategoryTable: UITableView!
    @IBOutlet weak var txtCurrentWeight: UITextField!
    var subCategories = [SubCategoryModel]()
    
    var selectedSubCategoriesFromTable = [Int]()
    
    var isAnsweredLostOrGainWeight = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subCategories = selectedSubCategoriesSingleton
        print("SubCategories:",subCategories)
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func yesBtnActionLostOrGainWeight(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: true)
        trainerTestAnswers.lostOrGainWeightInSixMonths = true
    }
    
    @IBAction func noBtnActionLostOrGainWeight(_ sender: Any) {
        colorChangeSelectedAnswerButton(button: false)
        trainerTestAnswers.lostOrGainWeightInSixMonths = false
    }
    
    func colorChangeSelectedAnswerButton(button: Bool) {
        
        isAnsweredLostOrGainWeight = true
        if button{
            btnYesLostOrGainWeight.backgroundColor = .blue
            btnNoLostOrGainWeight.backgroundColor = .lightGray
        }else{
            btnYesLostOrGainWeight.backgroundColor = .lightGray
            btnNoLostOrGainWeight.backgroundColor = .blue
        }
    }

    @IBAction func nextButtonAction(_ sender: Any) {
        
        if txtCurrentWeight.text == "" || !isAnsweredLostOrGainWeight{
            CommonMethods.alertView(view: self, title: ALERT_TITLE, message: PLEASE_ANSWER_ABOVE_QUESTIONS, buttonTitle: "OK")
        }else{
            trainerTestAnswers.currentWeight = txtCurrentWeight.text!
            loadSelectedSubCategoriesAmong()
            performSegue(withIdentifier: "afterSubCategorySelectionSegue", sender: self)
        }
    }
    
    func loadSelectedSubCategoriesAmong() {
        for value in selectedSubCategoriesFromTable{
            selectedSubCategoriesAmongSingleton.append(subCategories[value])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SubCategorySelectionVC: UITableViewDataSource{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: SubCategoryTableCell = tableView.dequeueReusableCell(withIdentifier: "subCategoryCellId") as! SubCategoryTableCell
        
        cell.lblSubCategoryName.text = subCategories[indexPath.row].subCategoryName
        
        if selectedSubCategoriesFromTable.contains(indexPath.row){
            cell.cellSelectionView.backgroundColor = UIColor.blue
        }else{
            cell.cellSelectionView.backgroundColor = UIColor.lightGray
        }

        return cell
    }
}

extension SubCategorySelectionVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        if selectedSubCategoriesFromTable.contains(indexPath.row){
            print("Cell deselected")
            selectedSubCategoriesFromTable.remove(at: selectedSubCategoriesFromTable.index(of: indexPath.row)!)
        }else{
            print("Cell Selected")
            selectedSubCategoriesFromTable.append(indexPath.row)
        }
        subCategoryTable.reloadRows(at: [indexPath], with: .automatic)
    }
}
