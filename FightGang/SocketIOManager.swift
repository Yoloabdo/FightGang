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
    
    let socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "https://fightgang.herokuapp.com")!)
    
    override init() {
        super.init()
    }
    
    struct Constants {
        static let notficationName = "checkSocket"
    }
    
    func establishConnection() {
        socket.connect()
        print("connected")
        
        socket.onAny { (event) in
            NSNotificationCenter.defaultCenter().postNotificationName(SocketIOManager.Constants.notficationName, object: nil)
            
        }
    }
    
    
    func closeConnection() {
        socket.disconnect()
    }
    
    
    func arenaCheck(completionHandler: AnyObject -> Void) {
        socket.on("arena") { (dataArray, emit) in
            completionHandler(dataArray[0] as! [[String: AnyObject]])
        }
        
        socket.on("attack") { (dataArray, emit) in
            completionHandler(dataArray[0] as! [[String: AnyObject]])
        }
        
    }

    func playersHeal(completionHandler: AnyObject -> Void) {
        socket.on("heal") { (dataArray, emit) in
            completionHandler(dataArray[0] as! [[String: AnyObject]])
        }
    }

    func chatUpdates(completionHandler: AnyObject -> Void) {
        socket.on("chat") { (dataArray, emit) in
            completionHandler(dataArray[0] as! [[String: AnyObject]])
        }
    }
    func off() -> Void {
        socket.off("arena")
        socket.off("attack")
        socket.off("heal")
        socket.off("chat")
    }
    
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> SocketIOManager {
        struct Singleton {
            static var sharedInstance = SocketIOManager()
        }
        return Singleton.sharedInstance
    }

}