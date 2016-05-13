//
//  ChatLog.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/13/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import Foundation

class ChatLog: NSObject {
    var timeStamp: Int!
    var message: String!
    var sender: String!
    
    init(obj: JsonObject) {
        guard let time = obj["timestamp"] as? Int else{
            print("Error parsing time")
            return
        }
        
        guard let message = obj["message"] as? String else {
            print("Error parsing message")
            return
        }
        
        guard let sender = obj["from"] as? String else {
            print("Error parsing sender")
            return
        }
        
        timeStamp = time
        self.message = message
        self.sender = sender
    }
}