//
//  SocketIOManager.swift
//  BuddyApp
//
//  Created by Ti Technologies on 09/08/17.
//  Copyright © 2017 Ti Technologies. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    
    static let sharedInstance = SocketIOManager()
    var datadict = NSMutableDictionary()
    var parameterdict = NSMutableDictionary()
    var paramary = NSMutableArray()
    
    //let socket = SocketIOClient(socketURL: NSURL(string: SERVER_URL)!, options: [.Log(true), .ForcePolling(true),SocketIOClientOption.connectParams(["__sails_io_sdk_version":"0.11.0","token":appDelegate.Usertoken] as [String: Any])])
    
    let socket = SocketIOClient(socketURL: URL(string: SERVER_URL)!, config: [.log(true), .compress, SocketIOClientOption.connectParams(["__sails_io_sdk_version":"0.12.13", "token":appDelegate.Usertoken,"user_type":appDelegate.USER_TYPE])])
    
    //       let socket = SocketIOClient(socketURL: NSURL(string:SERVER_URL)!, options: [SocketIOClientOption.ConnectParams(["__sails_io_sdk_version":"0.11.0"])])
    //
    
    override init() {
        super.init()
    }
    func ConnectionStatus() {
        print("CONNECTION STATUS",socket.status)
     
      
    }
    func establishConnection() {
        print("ESTABLISH CONNECTION")
        socket.connect()
        
    }
    
    func closeConnection() {
        socket.disconnect()
        
       
    }
    //////JOSE
    
    
    
    func OnSocket() {
        self.socket.on("connect") {data, ack in
            print("socket connected1")
            // self.connectToServerWithParams(params: parameters)
        }
    }
    //////////
    func EmittSocketParameters(parameters: NSMutableDictionary) {
        self.socket.on("connect") {data, ack in
            print("socket connected1")
            self.connectToServerWithParams(params: parameters)
        }
    }
    
    func connectToServerWithParams(params:NSMutableDictionary) {
            print("socket params",params)
            socket.emit("get", params)
            // getdata()
    }
    
    func getSocketdata(completionHandler: @escaping (_ messageInfo: NSMutableDictionary) -> Void) {
        socket.on("message") { (dataArray, socketAck) -> Void in
                var messageDictionary = NSMutableDictionary()
                messageDictionary = dataArray[0] as! NSMutableDictionary
                completionHandler(messageDictionary)
        }
    }
}
