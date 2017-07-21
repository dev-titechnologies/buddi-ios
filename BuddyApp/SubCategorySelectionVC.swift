//
//  SubCategorySelectionVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 20/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class SubCategorySelectionVC: UIViewController {

    @IBOutlet weak var subCategoryTable: UITableView!
    var subCategories = [SubCategoryModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("SubCategories:",subCategories)
    }

    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//extension SubCategorySelectionVC: UITableViewDataSource{
//   
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return subCategories.count
//    }
//    
////    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        
////    }
//}

extension SubCategorySelectionVC: UITableViewDelegate {
    
}
