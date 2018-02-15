//
//  WalletHistoryDetailVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 30/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import UIKit

class WalletHistoryDetailVC: UIViewController {
    
    @IBOutlet weak var imgFromIcon: UIImageView!
    @IBOutlet weak var imgToIcon: UIImageView!
    @IBOutlet weak var lblTransactionDescription: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    @IBOutlet weak var lblLabel1: UILabel!
    @IBOutlet weak var lblLabel11: UILabel!
    
    @IBOutlet weak var lblLabel2: UILabel!
    @IBOutlet weak var lblLabel22: UILabel!
    
    @IBOutlet weak var lblLabel3: UILabel!
    @IBOutlet weak var lblLabel33: UILabel!
    
    @IBOutlet weak var lblLabel4: UILabel!
    @IBOutlet weak var lblLabel44: UILabel!
    
    @IBOutlet weak var lblLabel5: UILabel!
    @IBOutlet weak var lblLabel55: UILabel!
    
    @IBOutlet weak var lblLabel6: UILabel!
    @IBOutlet weak var lblLabel66: UILabel!
    
    @IBOutlet weak var lblLabel7: UILabel!
    @IBOutlet weak var lblLabel77: UILabel!
    
    let transactionTypeIncomeForTrainee = "Income"
    let transactionTypeExpenseForTrainee = "Expense"
    
    let transactionTypeIncomeForTrainer = "Income"
    let transactionTypeExpenseForTrainer = "Withdraw"
    
    var traineeWalletHistoryModelObj = TraineeWalletHistoryModel()
    var trainerWalletHistoryModelObj = TrainerWalletHistoryModel()
    
    var profileArray = Array<ProfileDB>()
    var imageArray = Array<ProfileImageDB>()
    var userImage = UIImage()
    var userImageURL = String()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("** viewWillAppear **")
        
        getProfileImageOfUser()

        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
            parseDetailsForTrainee()
        }else if appDelegate.USER_TYPE == USER_TYPE.TRAINER{
            parseDetailsForTrainer()
        }
    }
    
    func getProfileImageOfUser() {
        
        if let imagearray = ProfileImageDB.fetchImage() {
            self.imageArray = imagearray as! Array<ProfileImageDB>
            
            if self.imageArray.count > 0 {
                let objData = self.imageArray[0].value(forKey: "imageData") as! NSData
                self.userImage = UIImage(data: objData as Data)!
            }else{
                self.userImage = #imageLiteral(resourceName: "profileDemoImage")
            }
        }
    }
    
    func parseDetailsForTrainee() {
        print("** parseDetailsForTrainee **")
        
        if traineeWalletHistoryModelObj.transactionType == transactionTypeIncomeForTrainee{
            //INCOME
            
            if traineeWalletHistoryModelObj.type == "stripe" {
                
                imgFromIcon.image = #imageLiteral(resourceName: "bank-building")
                imgToIcon.image = #imageLiteral(resourceName: "wallet")
                lblTransactionDescription.text = "Wallet recharged"
                lblAmount.text = CommonMethods.showWalletAmountInFloat(amount: traineeWalletHistoryModelObj.amount)
                
                lblLabel1.text = "Status"
                lblLabel11.text = ": \(PAYMENT_SUCCESSFULL)"
                
                lblLabel2.text = "Transaction ID"
                lblLabel22.text = ": \(traineeWalletHistoryModelObj.transactionId)"
                
                lblLabel3.text = "Date"

                lblLabel33.text = ": \(CommonMethods.dateFormatterTest5(date: CommonMethods.getDateFromString(dateString: traineeWalletHistoryModelObj.date)))"
                lblLabel4.isHidden = true
                lblLabel44.isHidden = true
                
                lblLabel5.isHidden = true
                lblLabel55.isHidden = true

                lblLabel6.isHidden = true
                lblLabel66.isHidden = true

                lblLabel7.isHidden = true
                lblLabel77.isHidden = true
                
            }else if traineeWalletHistoryModelObj.type == "refund"{
                
                imgFromIcon.image = #imageLiteral(resourceName: "buddi_icon")
                imgToIcon.image = #imageLiteral(resourceName: "wallet")
                lblTransactionDescription.text = "Refunded amount to Wallet"
                lblAmount.text = CommonMethods.showWalletAmountInFloat(amount: traineeWalletHistoryModelObj.amount)

                lblLabel1.text = "Status"
                lblLabel11.text = ": \(REFUND_SUCCESSFULL)"
                
                lblLabel2.text = "Session"
                lblLabel22.text = ": \(traineeWalletHistoryModelObj.sessionName)"
                
                lblLabel3.text = "Duration"
                lblLabel33.text = ": \(traineeWalletHistoryModelObj.sessionDuration) Minutes"
                
                lblLabel4.text = "Trainer"
                lblLabel44.text = ": \(traineeWalletHistoryModelObj.trainerName)"

                lblLabel5.text = "Date"
                lblLabel55.text = ": \(CommonMethods.dateFormatterTest5(date: CommonMethods.getDateFromString(dateString: traineeWalletHistoryModelObj.date)))"
                
                lblLabel6.isHidden = true
                lblLabel66.isHidden = true
                
                lblLabel7.isHidden = true
                lblLabel77.isHidden = true
            }
        }else{
            //EXPENSE
            
//            imgFromIcon.sd_setImage(with: URL(string: self.userImageURL), placeholderImage: UIImage(named: "profileDemoImage"))
            imgFromIcon.image = self.userImage
            
            imgFromIcon.layer.masksToBounds = false
            imgFromIcon.layer.cornerRadius = imgFromIcon.frame.size.height/2
            imgFromIcon.clipsToBounds = true

//            imgFromIcon.image = self.userImage
            
            imgToIcon.image = #imageLiteral(resourceName: "buddi_icon")
            lblTransactionDescription.text = "You paid to Buddi"
            lblAmount.text = CommonMethods.showWalletAmountInFloat(amount: traineeWalletHistoryModelObj.amount)

            lblLabel1.text = "Status"
            lblLabel11.text = ": \(PAYMENT_SUCCESSFULL)"
            
            lblLabel2.text = "Session"
            lblLabel22.text = ": \(traineeWalletHistoryModelObj.sessionName)"
            
            lblLabel3.text = "Duration"
            lblLabel33.text = ": \(traineeWalletHistoryModelObj.sessionDuration) Minutes"
            
            lblLabel4.text = "Trainer"
            lblLabel44.text = ": \(traineeWalletHistoryModelObj.trainerName)"
            
            lblLabel5.text = "Date"
            lblLabel55.text = ": \(CommonMethods.dateFormatterTest5(date: CommonMethods.getDateFromString(dateString: traineeWalletHistoryModelObj.date)))"
            
            lblLabel6.isHidden = true
            lblLabel66.isHidden = true
            
            lblLabel7.isHidden = true
            lblLabel77.isHidden = true
        }
    }
    
    func parseDetailsForTrainer() {
        print("** parseDetailsForTrainer **")
        
        if trainerWalletHistoryModelObj.transactionType == transactionTypeIncomeForTrainer{
            //INCOME
            
            imgFromIcon.image = #imageLiteral(resourceName: "buddi_icon")
            imgToIcon.image = self.userImage
            
            imgToIcon.layer.masksToBounds = false
            imgToIcon.layer.cornerRadius = imgToIcon.frame.size.height/2
            imgToIcon.clipsToBounds = true

            lblTransactionDescription.text = "Buddi paid to you"
            lblAmount.text = CommonMethods.showWalletAmountInFloat(amount: trainerWalletHistoryModelObj.amount)

            lblLabel1.text = "Status"
            lblLabel11.text = ": \(PAYMENT_SUCCESSFULL)"
            
            lblLabel2.text = "Session"
            lblLabel22.text = ": \(trainerWalletHistoryModelObj.sessionName)"
            
            lblLabel3.text = "Duration"
            lblLabel33.text = ": \(trainerWalletHistoryModelObj.sessionDuration) Minutes"
            
            lblLabel4.text = "Trainee"
            lblLabel44.text = ": \(trainerWalletHistoryModelObj.traineeName)"
            
            lblLabel5.text = "Date"
            lblLabel55.text = ": \(CommonMethods.dateFormatterTest5(date: CommonMethods.getDateFromString(dateString: trainerWalletHistoryModelObj.date)))"
            
            lblLabel6.isHidden = true
            lblLabel66.isHidden = true
            
            lblLabel7.isHidden = true
            lblLabel77.isHidden = true
        }else{
            //WITHDRAW
            
            imgFromIcon.image = #imageLiteral(resourceName: "wallet")
            imgToIcon.image = #imageLiteral(resourceName: "bank-building")
            lblTransactionDescription.text = "Withdrawn to bank account"
            lblAmount.text = CommonMethods.showWalletAmountInFloat(amount: trainerWalletHistoryModelObj.amount)

            lblLabel1.text = "Status"
            lblLabel11.text = ": \(PAYMENT_SUCCESSFULL)"
            
            lblLabel2.text = "Transaction ID"
            lblLabel22.text = ": \(trainerWalletHistoryModelObj.transactionId)"
            
            lblLabel3.text = "Date"
            
            lblLabel33.text = ": \(CommonMethods.dateFormatterTest5(date: CommonMethods.getDateFromString(dateString: trainerWalletHistoryModelObj.date)))"
            
            lblLabel4.isHidden = true
            lblLabel44.isHidden = true
           
            lblLabel5.isHidden = true
            lblLabel55.isHidden = true

            lblLabel6.isHidden = true
            lblLabel66.isHidden = true
            
            lblLabel7.isHidden = true
            lblLabel77.isHidden = true
        }
    }
}








