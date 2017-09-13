//
//  MessagingSocketVC.swift
//  BuddyApp
//
//  Created by Jithesh Xavier on 29/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessagingSocketVC: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var parameterdict = NSMutableDictionary()

    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()

    var sessionDetailModelObj: SessionDetailModel = SessionDetailModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero


    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        getMessagesFromServer()
        getSocketConnected()
        socketListener()
        
        if appDelegate.USER_TYPE == "trainer" {
            senderId = sessionDetailModelObj.trainerId
            senderDisplayName = sessionDetailModelObj.trainerName
        }else if appDelegate.USER_TYPE == "trainee"{
            senderId = sessionDetailModelObj.traineeId
            senderDisplayName = sessionDetailModelObj.traineeName
        }
    }
    
    func getMessagesFromServer() {
        
        let parameters = ["book_id" : sessionDetailModelObj.bookingId]
        let headers = [
            "token":appDelegate.Usertoken ]

        print("PARAMS: \(parameters)")
        CommonMethods.showProgress()
        CommonMethods.serverCall(APIURL: CHAT_HISTORY, parameters: parameters, headers: headers , onCompletion: { (jsondata) in
            print("Get Messages response:",jsondata)
            
            CommonMethods.hideProgress()
            if let status = jsondata["status"] as? Int{
                if status == RESPONSE_STATUS.SUCCESS{
                    
                    let messagesArray = jsondata["data"] as! NSArray as Array
                    for message in messagesArray{
                        self.messages.append(self.getJSQMessageModelFromDict(dictionary: message as! Dictionary<String, Any>))
                    }
                    print("Messages Received:\(self.messages)")
                    self.finishReceivingMessage()
                    
                }else if status == RESPONSE_STATUS.FAIL{
                    CommonMethods.alertView(view: self, title: ALERT_TITLE, message: jsondata["message"] as? String, buttonTitle: "OK")
                }else if status == RESPONSE_STATUS.SESSION_EXPIRED{
                    self.dismissOnSessionExpire()
                }
            }
        })
    }
    
    func getJSQMessageModelFromDict(dictionary: Dictionary<String, Any>) -> JSQMessage {
        
        let message = JSQMessage(senderId:String(describing: dictionary["from_id"]!),
                                 displayName: dictionary["from_name"] as! String,
                                 text: dictionary["message"] as! String)
        
        return message!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: - SOCKET FUNCTIONS

extension MessagingSocketVC {
    
    func getSocketConnected() {
        parameterdict.setValue("/connectSocket/connectSocket", forKey: "url")
        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
    }
    
    func socketListener() {
        SocketIOManager.sharedInstance.getSocketdata { (messageInfo) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                print("Initial Socket Connection in Message Page",messageInfo)
                
                guard messageInfo["type"] as! String == "chat" else{
                    print("**** Socket data received inside message screen without type 'chat'")
                    return
                }
                
                let socketDict = messageInfo["message"] as! NSDictionary
                
                guard socketDict["from_id"] as! Int != appDelegate.UserId else{
                    print("Same users message has been received through socket, hence returned")
                    return
                }
                
                let fromId = String(describing: socketDict["from_id"])
                let fromDisplayName = socketDict["from_name"] as! String
                let messageReceived = socketDict["text"] as! String
                
                if let message = JSQMessage(senderId: fromId, displayName: fromDisplayName, text: messageReceived){
                    print("Received Message :\(message)")
                    self.messages.append(message)
                    self.finishReceivingMessage()
                }
            })
        }
    }
    
    func sendMessageSocket(messageText: String) {
        
        let parameterdict = NSMutableDictionary()
        let datadict = NSMutableDictionary()
        
        let toId = (appDelegate.USER_TYPE == "trainer" ? sessionDetailModelObj.traineeId : sessionDetailModelObj.trainerId)
        
        datadict.setValue(sessionDetailModelObj.bookingId, forKey: "book_id")
        datadict.setValue(appDelegate.UserId, forKey: "from_id")
        datadict.setValue(toId, forKey: "to_id")
        datadict.setValue(messageText, forKey: "message")
        
        parameterdict.setValue("/chat/sendMessage", forKey: "url")
        parameterdict.setValue(datadict, forKey: "data")
        print("Send Message Param Dict:",parameterdict)
//        SocketIOManager.sharedInstance.EmittSocketParameters(parameters: parameterdict)
        SocketIOManager.sharedInstance.connectToServerWithParams(params: parameterdict)
    }
}

//MARK: - JSQMessagingVC Functions

extension MessagingSocketVC {
    
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
        return messages[indexPath.item].senderId! == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!){
        
        getSocketConnected()
        
        if let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text){
            sendMessageSocket(messageText: text)
            self.messages.append(message)
            self.finishSendingMessage()
        }
    }
}
