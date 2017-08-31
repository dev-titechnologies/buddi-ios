//
//  MessagingVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 28/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class MessagingVC: JSQMessagesViewController {
    
    var databaseChats: FIRDatabaseReference = FIRDatabaseReference()
    var sessionDetailModelObj: SessionDetailModel = SessionDetailModel()
    
    var messages = [JSQMessage]()
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        print("*** Session Detail Model Object in Messaging Page with Session Id: \(sessionDetailModelObj.bookingId)")
        
        if appDelegate.USER_TYPE == "trainer" {
            senderId = sessionDetailModelObj.trainerId
            senderDisplayName = sessionDetailModelObj.trainerName
        }else if appDelegate.USER_TYPE == "trainee"{
            senderId = sessionDetailModelObj.traineeId
            senderDisplayName = sessionDetailModelObj.traineeName
        }
        
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        databaseChats = Constants.refs.databaseRoot.child("bookingID_\(sessionDetailModelObj.bookingId)")
        
        let query = databaseChats.queryLimited(toLast: 10)
        
        _ = query.observe(.childAdded, with: { [weak self] snapshot in
            
            if  let data        = snapshot.value as? [String: String],
                let id          = data["sender_id"],
                let name        = data["name"],
                let text        = data["text"],
              
                !text.isEmpty{
                if let message = JSQMessage(senderId: id, displayName: name, text: text){
                    self?.messages.append(message)
                    self?.finishReceivingMessage()
                }
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("Booking ID: \(sessionDetailModelObj.bookingId)")
    }
    
    func firebaseChatListener() {
        
//        let bookingId = "bookingID_" + trainerProfileDetails.Booking_id
//        print("Firebase Chat listener booking id:\(bookingId)")
//        FIRDatabase
//            .database()
//            .reference(withPath:bookingId)
//            .observe(FIRDataEventType.value, with: { (snapshot) in
//                print("Firebase Data Updated")
//            }
//        )
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - JSQMessagingVC Functions

extension MessagingVC {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!{
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!{
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!{
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!{
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat{
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!){
        
        let ref = databaseChats.childByAutoId()
        let message = ["sender_id": senderId, "name": senderDisplayName, "text": text]
        ref.setValue(message)
        finishSendingMessage()
    }
}
