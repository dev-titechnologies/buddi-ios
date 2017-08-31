//
//  InviteFriendsVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 30/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import Contacts

class InviteFriendsVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var friendsListTable: UITableView!
    
    var contacts = [CNContact]()
    
    //MARK: - VIEW CYCLES
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = PAGE_TITLE.INVITE_FRIENDS
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        fetchContactsFromDevice()
        

//        let status = CNContactStore.authorizationStatus(for: .contacts)
//        if status == .denied || status == .restricted {
//            presentSettingsActionSheet()
//            return
//        }else{
//            fetchContactsFromDevice()
//        }
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
            
            // get the contacts
            
            let keysToFetch = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
            let request = CNContactFetchRequest(keysToFetch: keysToFetch as [CNKeyDescriptor])
            do {
                try store.enumerateContacts(with: request) { contact, stop in
                    self.contacts.append(contact)
                }
            } catch {
                print(error)
            }
            
            print("Contact Count:",self.contacts.count)
            self.friendsListTable.reloadData()

            // do something with the contacts array (e.g. print the names)
            
//            let formatter = CNContactFormatter()
//            formatter.style = .fullName
//            for contact in self.contacts {
//                let name: String? = CNContactFormatter.string(from: contact, style: .fullName)
////                print("Contact:\(String(describing: name))")
//            }
            
        }
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - TABLEVIEW DATASOURCE

extension InviteFriendsVC : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: InviteFriendsCell = tableView.dequeueReusableCell(withIdentifier: "inviteFriendsCellId") as! InviteFriendsCell

        let contact = contacts[indexPath.row]
        print("Contact123:",contact)
        let MobNumVar = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
        print("Mobile:",MobNumVar)
        cell.lblContactName.text = CNContactFormatter.string(from: contact, style: .fullName)

        return cell
    }
}

//MARK: - TABLEVIEW DELEGATES

extension InviteFriendsVC : UITableViewDelegate{
    
}
