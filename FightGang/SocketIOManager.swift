//
//  SocketIOManager.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/12/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import Foundation
import SocketIOClientSwift

class SocketIOManager: NSObject {
    
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "https://fightgang.herokuapp.com")!)
    
    override init() {
        super.init()
    }
    
    
    func establishConnection() {
        socket.connect()
        print("connected")
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    
    
    
    // connect with id 
    func connectToServerWithID(id: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
        socket.emit("connectUser", id)
        
        socket.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
        }
    }
    
    
    
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> SocketIOManager {
        struct Singleton {
            static var sharedInstance = SocketIOManager()
        }
        return Singleton.sharedInstance
    }

}