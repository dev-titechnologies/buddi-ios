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
    
    let traineeWalletHistoryArray = [TraineeWalletHistoryModel]()
    let trainerWalletHistoryArray = [TrainerWalletHistoryModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func getTrainerIncomeCell(_ tableView: UITableView, index_path: IndexPath) -> TrainerIncomeCell {

        let trainerIncomeCell: TrainerIncomeCell = tableView.dequeueReusableCell(withIdentifier: trainerIncomeCellId) as! TrainerIncomeCell

        return trainerIncomeCell
    }
    
    func getTrainerExpenseCell(_ tableView: UITableView, index_path: IndexPath) -> TrainerExpenseCell {
        
        let trainerExpenseCell: TrainerExpenseCell = tableView.dequeueReusableCell(withIdentifier: trainerExpenseCellId) as! TrainerExpenseCell

        return trainerExpenseCell
    }
    
    func getTraineeIncomeCell(_ tableView: UITableView, index_path: IndexPath) -> TraineeIncomeCell {
        
        let traineeIncomeCell: TraineeIncomeCell = tableView.dequeueReusableCell(withIdentifier: traineeIncomeCellId) as! TraineeIncomeCell

        return traineeIncomeCell
    }
    
    func getTraineeExpenseCell(_ tableView: UITableView, index_path: IndexPath) -> TraineeExpenseCell {
        
        let traineeExpenseCell: TraineeExpenseCell = tableView.dequeueReusableCell(withIdentifier: traineeExpenseCellId) as! TraineeExpenseCell


        return traineeExpenseCell
    }
}

extension WalletHistory: UITableViewDelegate{
    
}
