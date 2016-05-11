//
//  User.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/11/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import Foundation

class User: NSObject {
    
    var id: Int?
    
    var alias: String?
    
    var level: Int?
    
    var hits: Int?
    
    var stamina: Int?
    
    var maxStamina: Int?
    
    
    
    init(id: Int, alias: String, level: Int, hits: Int, stamina: Int, maxStamina: Int) {
        self.id = id
        self.alias = alias
        self.level = level
        self.hits = hits
        self.stamina = stamina
        self.maxStamina = maxStamina
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        guard let id = dictionary["id"] as? Int else {
            print("Couldn't interpret ID")
            return
        }
        guard let alias = dictionary["alias"] as? String else {
            print("Couldn't interpret alias")
            return
        }
        
        guard let level = dictionary["level"] as? Int else {
            print("Couldn't interpret level")
            return
        }

        guard let hits = dictionary["hits"] as? Int else {
            print("Couldn't interpret hits")
            return
        }

        guard let stamina = dictionary["stamina"] as? Int else {
            print("Couldn't interpret stamina")
            return
        }
        
        guard let maxStamina = dictionary["maxStamina"] as? Int else {
            print("Couldn't interpret maxStamina")
            return
        }

        self.id = id
        self.alias = alias
        self.level = level
        self.hits = hits
        self.stamina = stamina
        self.maxStamina = maxStamina
        

    }
    
}