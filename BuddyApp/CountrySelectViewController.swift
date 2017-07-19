//
//  CountrySelectViewController.swift
//  BuddyApp
//
//  Created by Ti Technologies on 19/07/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit

class CountrySelectViewController: UIViewController {
    @IBOutlet weak var countryTable: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    var countryArray = [AnyObject]()
    var arrayFiltered = [AnyObject]()
    var isSearching = Bool()
    var countryCode = String()
    var countryAlphaCode = String()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let filepath = Bundle.main.path(forResource: "countrycodes", ofType: "json")
        let data = NSData.init(contentsOfFile: filepath!)
        do{
            countryArray = try JSONSerialization.jsonObject(with: data! as Data, options: []) as! [AnyObject]
        }catch{
            print("Values cannot be fetched from JSON file")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
//extension CountrySelectViewController : UITableViewDataSource,UITableViewDelegate{
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        //        return (isSearching == true? arrayFiltered.count : countryArray.count)
//        if(isSearching){
//            return arrayFiltered.count
//        }else{
//            return countryArray.count
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
//        let cell :SelectCountryCell = tableView.dequeueReusableCell(withIdentifier: "countrycellid") as! SelectCountryCell
//        
//        if(isSearching && arrayFiltered.count>0){
//            
//            cell.lblCountryCode.text = arrayFiltered[indexPath.row].value(forKey: "name")
//            
//    cell.lblCountryName.text = String(arrayFiltered[indexPath.row].value("name")!)
//            cell.lblCountryCode.text = "(\(String(arrayFiltered[indexPath.row].value("phone-code")!)))"
//        }else{
//            cell.lblCountryName.text = String(countryArray[indexPath.row].value("name")!)
//            cell.lblCountryCode.text = "(\(String(countryArray[indexPath.row].value("phone-code")!)))"
//        }
//        
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
//        if(isSearching){
//            countryCode = arrayFiltered[indexPath.row].value("phone-code") as! String
//            countryAlphaCode = arrayFiltered[indexPath.row].value("alpha-2") as! String
//            
//            UserDefaults.standard.set(arrayFiltered[indexPath.row].value("name") as! String, forKey: "countryname")
//        }else{
//            countryCode = countryArray[indexPath.row].value("phone-code") as! String
//            countryAlphaCode = countryArray[indexPath.row].value("alpha-2") as! String
//            
//            UserDefaults.standardUserDefaults.set(countryArray[indexPath.row].value("name") as! String, forKey: "countryname")
//        }
//        performSegue(withIdentifier: "unwindsegue", sender: self)
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let popOverVC = segue.destinationViewController as! SignUpViewController
//        popOverVC.countryCodeReceived = countryCode
//        popOverVC.countryAlphaCode = countryAlphaCode
//    }
//}
//
//extension CountrySelectViewController : UISearchBarDelegate{
//    
//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
//        arrayFiltered.removeAll()
//        convertButtonTitle(fromTitle: "Search", toTitle: "Cancel", inView: searchBar)
//        if(searchText.length != 0){
//            isSearching = true
//            searchTableList()
//        }else{
//            isSearching = false
//        }
//        countryTable.reloadData()
//    }
//    
//    func searchTableList() {
//        let searchString = searchBar.text
//        for dict in countryArray{
//            let tempName = dict.value("name")
//            if tempName!.lowercaseString.rangeOfString(searchString!.lowercaseString) != nil {
//                arrayFiltered.append(dict)
//            }
//        }
//        countryTable.reloadData()
//    }
//    
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//        searchTableList()
//    }
//    
//    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
//        searchBar.resignFirstResponder()
//    }
//    
//    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
//        //        convertButtonTitle("Cancel", toTitle: "Search", inView: searchBar)
//        searchBar.resignFirstResponder()
//        if(searchBar.text != ""){
//            searchBar.text = ""
//            isSearching = false
//            countryTable.reloadData()
//        }else{
//            self.performSegue(withIdentifier: "unwindsegue", sender: self)
//        }
//    }
//    
//    func convertButtonTitle(fromTitle:String,toTitle:String, inView:UIView) {
//        if(inView.isKindOfClass(UIButton)){
//            let button = inView as! UIButton
//            if(button.title(for: .normal) == fromTitle){
//                button.setTitle(toTitle, for: .normal)
//            }
//        }
//        
//        for subview in inView.subviews {
//            convertButtonTitle(fromTitle: fromTitle, toTitle: toTitle, inView: subview)
//        }
//    }
//    
//}
//
