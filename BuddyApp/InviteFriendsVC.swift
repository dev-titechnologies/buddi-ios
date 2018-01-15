//
//  InviteFriendsVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 30/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Contacts
import libPhoneNumber_iOS

class InviteFriendsVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var friendsListTable: UITableView!
    
    var contacts = [CNContact]()
    var contactArray = [ContactDictionaryModel]()
    
    //For Search
    var arrayFiltered = [ContactDictionaryModel]()
    var isSearching = Bool()
    var identifierArray = [String]()
    var selectedContactsArray = [String]()
    
    let phoneUtil = NBPhoneNumberUtil()

    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.INVITE_FRIENDS
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchContactsFromDevice()
    }
    
    func fetchContactsFromDevice() {
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                DispatchQueue.main.async {
                    self.presentSettingsActionSheet()
                }
                return
            }
            
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    self.contacts.append(contact)
                }
            } catch {
                print(error)
            }
            
            print("Contact Count:",self.contacts.count)
            for contact in self.contacts {
                
                print(contact.phoneNumbers)
                let contact_dict_model = ContactDictionaryModel()
                let contact_model = contact.getDictionaryFromCNContact
                
                contact_dict_model.status = "0"
                contact_dict_model.contact = contact_model
                
                if contact.phoneNumbers.count > 0 {
                    self.contactArray.append(contact_dict_model)
                    self.identifierArray.append(contact_model.identifier)
                }
            }
            
            self.friendsListTable.reloadData()
        }
    }
    
    @IBAction func inviteAction(_ sender: Any) {
        inviteFriendsServerCall()
    }
    
    func presentSettingsActionSheet() {
        let alert = UIAlertController(title: "Permission to Contacts", message: "This app needs access to contacts in order to invite friends", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func getMobileNumberFormatted(mobileNumber: String) -> String{
        
        do {
            let phoneNumber: NBPhoneNumber = try phoneUtil.parse(mobileNumber, defaultRegion: COUNTRY_DEFAULT_REGION_CODE)
            let formattedString: String = try phoneUtil.format(phoneNumber, numberFormat: .E164)
            print("Formatted String:\(formattedString)")
            return formattedString
        }
        catch let error as NSError {
            print(error.localizedDescription)
            return ""
        }
    }
    
    func inviteFriendsServerCall() {
        
        var userMobile = userDefaults.value(forKey: "userMobileNumber") as! String
        userMobile = userMobile.replacingOccurrences(of: "-", with: "")
        
        let parameters = ["mobile_array":selectedContactsArray,
                          "invited_mobile":userMobile
        ] as [String : Any]
        
        print("Params:",parameters)
        
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: INVITE_FRIENDS, parameters: parameters, onCompletion: { (jsondata) in
            print("INVITE FRIENDS RESPONSE",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "Ok")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - TABLEVIEW DATASOURCE

extension InviteFriendsVC : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rowCount = (isSearching ? arrayFiltered.count : contactArray.count)
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: InviteFriendsCell = tableView.dequeueReusableCell(withIdentifier: "inviteFriendsCellId") as! InviteFriendsCell
        
        var contact = ContactDictionaryModel()
        
        contact = (isSearching && arrayFiltered.count > 0 ? arrayFiltered[indexPath.row] : contactArray[indexPath.row])
        
        let dict = contact.contact
        cell.lblContactName.text = dict.givenName + " " + dict.familyName
        cell.imgCheck.image = (contact.status == "0" ?  #imageLiteral(resourceName: "unchecked") : #imageLiteral(resourceName: "checked"))

        return cell
    }
}

//MARK: - TABLEVIEW DELEGATES

extension InviteFriendsVC : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contact = (isSearching ? arrayFiltered[indexPath.row] : contactArray[indexPath.row])
        let temp_contact = ContactDictionaryModel()
       
        let phoneNumberArray = contact.contact.phoneNumbers[0] as! NSDictionary
        print(phoneNumberArray["number"] as! String)
        let formattedMobileNumber = getMobileNumberFormatted(mobileNumber: phoneNumberArray["number"] as! String)
        
        if contact.status == "0" {
            temp_contact.status = "1"
            temp_contact.contact = contact.contact as ContactModel
            print(contact.contact.phoneNumbers)
            selectedContactsArray.append(formattedMobileNumber)
            print("*** Selected Contact:\(selectedContactsArray)")
        }else{
            temp_contact.status = "0"
            temp_contact.contact = contact.contact as ContactModel
            
            if selectedContactsArray.contains(obj: formattedMobileNumber){
                print("Mobile Number found, Hence removed from selected Contacts array")
                selectedContactsArray = selectedContactsArray.filter { $0 != formattedMobileNumber }
                print(selectedContactsArray)
            }
        }
        
        if isSearching{
            arrayFiltered[indexPath.row] = temp_contact
            
            let indexOf = self.identifierArray.index(of: arrayFiltered[indexPath.row].contact.identifier)
            print("Index Found: \(String(describing: indexOf!))")
            contactArray[indexOf!] = temp_contact
        }else {
            contactArray[indexPath.row] = temp_contact
        }
        let indexPath1 = IndexPath(row: indexPath.row, section: 0)
        self.friendsListTable.reloadRows(at: [indexPath1], with: .automatic)
    }
}

extension Array {
    func contains<T>(obj: T) -> Bool where T : Equatable {
        return self.filter({$0 as? T == obj}).count > 0
    }
}

//MARK: - SEARCHBAR DELEGATES

extension InviteFriendsVC: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
       
        arrayFiltered.removeAll()
        convertButtonTitle(fromTitle: "Search", toTitle: "Cancel", inView: searchBar)
        
        print("*** Search Text:\(searchText)")
        if(searchText.characters.count != 0){
            isSearching = true
            searchTableList()
        }else{
            isSearching = false
        }
        friendsListTable.reloadData()
    }
    
    func searchTableList() {
        let searchString = searchBar.text
       
        for contact in contactArray{
            
            let contact_dict = contact.contact 
            print("contact_dict:\(contact_dict)")
            
            let given_name = contact_dict.givenName
            let family_name = contact_dict.familyName
            
            if given_name.lowercased().range(of: (searchString?.lowercased())!) != nil ||
                family_name.lowercased().range(of: (searchString?.lowercased())!) != nil {
                arrayFiltered.append(contact)
            }
        }
        
        print("Search Resultant Array :\(arrayFiltered)")
        friendsListTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchTableList()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        convertButtonTitle(fromTitle: "Cancel", toTitle: "Search", inView: searchBar)
        searchBar.resignFirstResponder()
        if(searchBar.text != ""){
            searchBar.text = ""
            isSearching = false
            friendsListTable.reloadData()
        }else{
//            self.performSegueWithIdentifier("unwindsegue", sender: self)
        }
    }
    
    func convertButtonTitle(fromTitle:String,toTitle:String, inView:UIView) {
       
        if inView.isKind(of: UIButton.self){
            let button = inView as! UIButton
            if button.title(for: .normal) == fromTitle{
                button.setTitle(toTitle, for: .normal)
            }
        }
        
        for subview in inView.subviews {
            convertButtonTitle(fromTitle: fromTitle, toTitle: toTitle, inView: subview)
        }
    }
}

//MARK: - CNCONTACT EXTENSION

extension CNContact {
    var getDictionaryFromCNContact : ContactModel {
        
        let contact = ContactModel()
        let phoneNumbers = NSMutableArray()
        
        contact.identifier         = self.identifier as String
        contact.givenName          = self.givenName as String
        contact.familyName         = self.familyName as String
        //        contact["imageDataAvailable"] = self.imageDataAvailable as AnyObject
        
        //        if (self.imageDataAvailable) {
        //            let thumbnailImageDataAsBase64String = self.thumbnailImageData!.base64EncodedStringWithOptions([])
        //            contact["thumbnailImageData"] = thumbnailImageDataAsBase64String
        //        }
        
        if (self.isKeyAvailable(CNContactPhoneNumbersKey)) {
            for number in self.phoneNumbers {
                var numbers = [String: String]()
                let phoneNumber = (number.value ).value(forKey: "digits") as! String
                let countryCode = (number.value ).value(forKey: "countryCode") as? String
                //                let label = CNLabeledValue.localizedString(forLabel: number.label!)
                numbers["number"] = phoneNumber
                numbers["countryCode"] = countryCode
                //                numbers["label"] = label
                phoneNumbers.add(numbers)
            }
            contact.phoneNumbers = phoneNumbers
        }
        
        return contact
    }
}

