//
//  WalletHistory.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 25/01/18.
//  Copyright © 2018 Ti Technologies. All rights reserved.
//

import UIKit

class WalletHistory: UIViewController {

    @IBOutlet weak var walletHistoryTable: UITableView!
    
    let trainerIncomeCellId = "trainerIncomeCellId"
    let trainerExpenseCellId = "trainerExpenseCellId"
    let traineeIncomeCellId = "traineeIncomeCellId"
    let traineeExpenseCellId = "traineeExpenseCellId"
    
    //Trainer
    let transactionTypeIncomeForTrainer = "Income"
    let transactionTypeExpenseForTrainer = "Withdraw"
    
    //Trainee
    let transactionTypeIncomeForTrainee = "Income"
    let transactionTypeExpenseForTrainee = "Expense"
    
    var traineeWalletHistoryArray = [TraineeWalletHistoryModel]()
    var trainerWalletHistoryArray = [TrainerWalletHistoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.WALLET_HISTORY
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchWalletHistory()
        
        
    }
    
    func fetchWalletHistory() {
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: WALLET_HISTORY, parameters: [:]) { (jsondata) in
            print("** fetchWalletHistory Response: \(jsondata)")
            
            CommonMethods.hideProgress()
            guard (jsondata["status"] as? Int) != nil else {
                CommonMethods.alertView(view: self, title: ALERT_TITLE, message: SERVER_NOT_RESPONDING, buttonTitle: "OK")
                return
            }
            
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    if let resultData = jsondata["data"] as? NSArray {
                        print("** resultData: \(resultData)")
                        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
                            self.traineeWalletHistoryArray.removeAll()
                            self.traineeWalletHistoryArray = self.getTraineeHistoryModelArray(historyArray: resultData)
                            self.walletHistoryTable.reloadData()
                        }else if appDelegate.USER_TYPE == USER_TYPE.TRAINER{
                            self.trainerWalletHistoryArray.removeAll()
                            self.trainerWalletHistoryArray = self.getTrainerHistoryModelArray(historyArray: resultData)
                            self.walletHistoryTable.reloadData()
                        }
                    }else{
                        CommonMethods.alertView(view: self, title: ALERT_TITLE, message: NO_TRANSACTION_HISTORIES_FOUND, buttonTitle: "Ok")
                    }
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        }
    }
    
    func getTraineeHistoryModelArray(historyArray: NSArray) -> [TraineeWalletHistoryModel] {
        
        print("** getTraineeHistoryModelArray **")
        var traineeHistoryModelArray = [TraineeWalletHistoryModel]()
        
        for history in historyArray.enumerated(){
            
            print("History :\(history.element)")
            let history_dict = history.element as? Dictionary<String, Any>
            traineeHistoryModelArray.append(getTraineeWalletHistoryModel(historyDictionary: history_dict!))
        }
        
        return traineeHistoryModelArray
    }
    
    func getTrainerHistoryModelArray(historyArray: NSArray) -> [TrainerWalletHistoryModel] {
        
        print("** getTrainerHistoryModelArray **")
        var trainerHistoryModelArray = [TrainerWalletHistoryModel]()
        
        for history in historyArray.enumerated(){
            
            print("History :\(history.element)")
            let history_dict = history.element as? Dictionary<String, Any>
            trainerHistoryModelArray.append(getTrainerWalletHistoryModel(historyDictionary: history_dict!))
        }
        
        return trainerHistoryModelArray
    }
    
    //For Trainee
    func getTraineeWalletHistoryModel(historyDictionary: Dictionary<String, Any>) -> TraineeWalletHistoryModel {
        
        let traineeHistoryModel = TraineeWalletHistoryModel()
        
        if let trainsaction_id = historyDictionary["transaction_id"] as? String {
            traineeHistoryModel.transactionId = trainsaction_id
        }else{
            traineeHistoryModel.transactionId = ""
        }
        
        if let amount = historyDictionary["amount"] as? String {
            traineeHistoryModel.amount = amount
        }else{
            traineeHistoryModel.amount = ""
        }
        
        if let date = historyDictionary["date"] as? String {
            traineeHistoryModel.date = date
        }else{
            traineeHistoryModel.date = ""
        }
        
        if let transaction_type = historyDictionary["transaction_type"] as? String {
            traineeHistoryModel.transactionType = transaction_type
        }else{
            traineeHistoryModel.transactionType = ""
        }
        
        if let session_icon = historyDictionary["session_image"] as? String {
            traineeHistoryModel.sessionIcon = session_icon
        }else{
            traineeHistoryModel.sessionIcon = ""
        }
        
        if let session_name = historyDictionary["session_name"] as? String {
            traineeHistoryModel.sessionName = session_name
        }else{
            traineeHistoryModel.sessionName = ""
        }
        
        if let trainer_name = historyDictionary["trainer_name"] as? String {
            traineeHistoryModel.trainerName = trainer_name
        }else{
            traineeHistoryModel.trainerName = ""
        }
        
        if let session_duration = historyDictionary["session_duration"] as? String {
            traineeHistoryModel.sessionDuration = session_duration
        }else{
            traineeHistoryModel.sessionDuration = ""
        }
        
        if let type = historyDictionary["type"] as? String {
            traineeHistoryModel.type = type
        }else{
            traineeHistoryModel.type = ""
        }
        
        return traineeHistoryModel
    }
    
    //For Trainer
    func getTrainerWalletHistoryModel(historyDictionary: Dictionary<String, Any>) -> TrainerWalletHistoryModel {
        
        let trainerHistoryModel = TrainerWalletHistoryModel()
        
        if let trainsaction_id = historyDictionary["transaction_id"] as? String {
            trainerHistoryModel.transactionId = trainsaction_id
        }else{
            trainerHistoryModel.transactionId = ""
        }
        
        if let amount = historyDictionary["amount"] as? String {
            trainerHistoryModel.amount = amount
        }else{
            trainerHistoryModel.amount = ""
        }
        
        if let date = historyDictionary["date"] as? String {
            trainerHistoryModel.date = date
        }else{
            trainerHistoryModel.date = ""
        }
        
        if let session_icon = historyDictionary["session_image"] as? String {
            trainerHistoryModel.sessionIcon = session_icon
        }else{
            trainerHistoryModel.sessionIcon = ""
        }
        
        if let session_name = historyDictionary["session_name"] as? String {
            trainerHistoryModel.sessionName = session_name
        }else{
            trainerHistoryModel.sessionName = ""
        }
        
        if let trainee_name = historyDictionary["trainee_name"] as? String {
            trainerHistoryModel.traineeName = trainee_name
        }else{
            trainerHistoryModel.traineeName = ""
        }
        
        if let session_duration = historyDictionary["session_duration"] as? String {
            trainerHistoryModel.sessionDuration = session_duration
        }else{
            trainerHistoryModel.sessionDuration = ""
        }
        
        if let type = historyDictionary["type"] as? String {
            trainerHistoryModel.transactionType = type
        }else{
            trainerHistoryModel.transactionType = ""
        }
        
        if let transaction_status = historyDictionary["transaction_status"] as? String {
            trainerHistoryModel.transactionStatus = transaction_status
        }else{
            trainerHistoryModel.transactionStatus = ""
        }
        
        return trainerHistoryModel
    }
}

extension WalletHistory: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
            return traineeWalletHistoryArray.count
        }else{
            return trainerWalletHistoryArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE {
            //TRAINEE
            
            if traineeWalletHistoryArray[indexPath.row].transactionType == transactionTypeIncomeForTrainee {
                print("**** TRAINEE INCOME CELL ****")
                return getTraineeIncomeCell(tableView, index_path: indexPath)
            }else{
                print("**** TRAINEE EXPENSE CELL ****")
                return getTraineeExpenseCell(tableView, index_path: indexPath)
            }
            
        }else{
            //TRAINER
            if trainerWalletHistoryArray[indexPath.row].transactionType == transactionTypeIncomeForTrainer {
                print("**** TRAINER INCOME CELL ****")
                return getTrainerIncomeCell(tableView, index_path: indexPath)
            }else {
                print("**** TRAINER WITHDRAW CELL ****")
                return getTrainerExpenseCell(tableView, index_path: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight = 0.0
        if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
            if traineeWalletHistoryArray[indexPath.row].transactionType == transactionTypeExpenseForTrainee {
                //EXPENSE
                rowHeight = 87.0
            }else if traineeWalletHistoryArray[indexPath.row].transactionType == transactionTypeIncomeForTrainee{
                //INCOME
                rowHeight = 87.0
            }
        }else if appDelegate.USER_TYPE == USER_TYPE.TRAINER{
            if trainerWalletHistoryArray[indexPath.row].transactionType == transactionTypeExpenseForTrainer {
                //EXPENSE
                rowHeight = 87.0
            }else if trainerWalletHistoryArray[indexPath.row].transactionType == transactionTypeIncomeForTrainer{
                //INCOME
                rowHeight = 87.0
            }
        }
        return CGFloat(rowHeight)
    }
    
    
    //MARK: - MODEL CLASS FUNCTIONS
    
    func getTrainerIncomeCell(_ tableView: UITableView, index_path: IndexPath) -> TrainerIncomeCell {

        let trainerIncomeCell: TrainerIncomeCell = tableView.dequeueReusableCell(withIdentifier: trainerIncomeCellId) as! TrainerIncomeCell
        
        let historyModelObj = trainerWalletHistoryArray[index_path.row]

        trainerIncomeCell.imgImageView.sd_setImage(with: URL(string: historyModelObj.sessionIcon), placeholderImage: UIImage(named: ""))
        trainerIncomeCell.lblAmount.text = "+ $ \(historyModelObj.amount)"
        trainerIncomeCell.lblAmount.textColor = CommonMethods.hexStringToUIColor(hex: INCOME_GREEN_COLOR)
        trainerIncomeCell.lblDate.text = CommonMethods.convert24hrsTo12hrs(date: CommonMethods.getDateFromString(dateString: historyModelObj.date))

        return trainerIncomeCell
    }
    
    func getTrainerExpenseCell(_ tableView: UITableView, index_path: IndexPath) -> TrainerExpenseCell {
        
        let trainerExpenseCell: TrainerExpenseCell = tableView.dequeueReusableCell(withIdentifier: trainerExpenseCellId) as! TrainerExpenseCell
        
        let historyModelObj = trainerWalletHistoryArray[index_path.row]

        trainerExpenseCell.lblAmount.text = "- $ \(historyModelObj.amount)"
        trainerExpenseCell.lblAmount.textColor = CommonMethods.hexStringToUIColor(hex: EXPENSE_RED_COLOR)
        trainerExpenseCell.lblDate.text = CommonMethods.convert24hrsTo12hrs(date: CommonMethods.getDateFromString(dateString: historyModelObj.date))

        return trainerExpenseCell
    }
    
    func getTraineeIncomeCell(_ tableView: UITableView, index_path: IndexPath) -> TraineeIncomeCell {
        
        let traineeIncomeCell: TraineeIncomeCell = tableView.dequeueReusableCell(withIdentifier: traineeIncomeCellId) as! TraineeIncomeCell

        let historyModelObj = traineeWalletHistoryArray[index_path.row]
        
        if historyModelObj.type == "stripe" {
            traineeIncomeCell.lblSessionNameOrTransId.text = "Wallet Recharge"
            traineeIncomeCell.imgImageView.image = #imageLiteral(resourceName: "wallet")
        }else if historyModelObj.type == "refund"{
            traineeIncomeCell.lblSessionNameOrTransId.text = historyModelObj.sessionName
            traineeIncomeCell.imgImageView.image = #imageLiteral(resourceName: "buddi_icon")
        }
        traineeIncomeCell.lblAmount.text = "+ $ \(historyModelObj.amount)"
        traineeIncomeCell.lblAmount.textColor = CommonMethods.hexStringToUIColor(hex: INCOME_GREEN_COLOR)
        traineeIncomeCell.lblDate.text = CommonMethods.convert24hrsTo12hrs(date: CommonMethods.getDateFromString(dateString: historyModelObj.date))
        
        return traineeIncomeCell
    }
    
    func getTraineeExpenseCell(_ tableView: UITableView, index_path: IndexPath) -> TraineeExpenseCell {
        
        let traineeExpenseCell: TraineeExpenseCell = tableView.dequeueReusableCell(withIdentifier: traineeExpenseCellId) as! TraineeExpenseCell

        let historyModelObj = traineeWalletHistoryArray[index_path.row]

        traineeExpenseCell.imgImageView.sd_setImage(with: URL(string: historyModelObj.sessionIcon), placeholderImage: UIImage(named: ""))
        traineeExpenseCell.lblSessionName.text = historyModelObj.sessionName
        traineeExpenseCell.lblAmount.text = "- $ \(historyModelObj.amount)"
        traineeExpenseCell.lblAmount.textColor = CommonMethods.hexStringToUIColor(hex: EXPENSE_RED_COLOR)
        traineeExpenseCell.lblDate.text = CommonMethods.convert24hrsTo12hrs(date: CommonMethods.getDateFromString(dateString: historyModelObj.date))

        return traineeExpenseCell
    }
}

extension WalletHistory: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "walletHistoryDetailSegue", sender: self)
    }
    
    //MARK: - PREPARE FOR SEGUE ACTIONS
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "walletHistoryDetailSegue"{
            
            let walletHistoryDetailPageObj = segue.destination as! WalletHistoryDetailVC

            if appDelegate.USER_TYPE == USER_TYPE.TRAINEE{
                walletHistoryDetailPageObj.traineeWalletHistoryModelObj = traineeWalletHistoryArray[(walletHistoryTable.indexPathForSelectedRow?.row)!]
                
            }else if appDelegate.USER_TYPE == USER_TYPE.TRAINER{
                walletHistoryDetailPageObj.trainerWalletHistoryModelObj = trainerWalletHistoryArray[(walletHistoryTable.indexPathForSelectedRow?.row)!]
            }
        }
    }
}
