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
    
    var socket: SocketIOClient

//    lazy var socket: SocketIOClient = {
//        return SocketIOClient(socketURL: mainURL, config: [.log(false), .compress, .connectParams(["token": "asdasdasdsa"])])
//    }()
    
    //let socket = SocketIOClient(socketURL: NSURL(string: SERVER_URL)!, options: [.Log(true), .ForcePolling(true),SocketIOClientOption.connectParams(["__sails_io_sdk_version":"0.11.0","token":appDelegate.Usertoken] as [String: Any])])
    
//    lazy var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: SERVER_URL)!, config: [.log(true), .compress, SocketIOClientOption.connectParams(["__sails_io_sdk_version":"0.12.13", "token":appDelegate.Usertoken,"user_type":appDelegate.USER_TYPE])])
    
    //       let socket = SocketIOClient(socketURL: NSURL(string:SERVER_URL)!, options: [SocketIOClientOption.ConnectParams(["__sails_io_sdk_version":"0.11.0"])])
    
    override init() {
        
        print("==================================")
        print("******* SOCKET CLIENT INIT *******")
        print("==================================")
        print("USER TOKEN:\(appDelegate.Usertoken)")
        print("USER TYPE:\(appDelegate.USER_TYPE)")

        socket = SocketIOClient(socketURL: URL(string: SERVER_URL)!, config: [.log(true), .compress, SocketIOClientOption.connectParams(["__sails_io_sdk_version":"0.12.13", "token":appDelegate.Usertoken,"user_type":appDelegate.USER_TYPE])])
        super.init()
    }
    
    func socketObjectReinit() {
        
        print("==================================")
        print("******* socketObjectReinit *******")
        print("==================================")

        socket = SocketIOClient(socketURL: URL(string: SERVER_URL)!, config: [.log(true), .compress, SocketIOClientOption.connectParams(["__sails_io_sdk_version":"0.12.13", "token":appDelegate.Usertoken,"user_type":appDelegate.USER_TYPE])])
    }

//    override init() {
//        super.init()
//    }
    
    func ConnectionStatus() {
        print("CONNECTION STATUS",socket.status)
    }
    
    func removeSocketInstances() {
        print("****** Removing Socket Instances ********")
        socket.removeAllHandlers()
    }
    
    func establishConnection() {
        print("ESTABLISH CONNECTION")
        socket.connect()
        
    }
    
    func reconnectSocket() {
        socket.reconnect()
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
