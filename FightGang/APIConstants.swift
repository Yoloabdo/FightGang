//
//  Constants.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/12/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import Foundation

extension APIManager {
    struct Constants {
        static let BaseURL = "https://fightgang.herokuapp.com/api"
        
        static let API_KEY = "p0x0XirrQV66w18372t8l91WCklUqq4K657tT1A06b6m10TuG6n6894S2IHFH3YP"
        
        static let userNameDefault = "user"
        static let userPassDefault = "password"
    }
    
    
    
    struct Methods {
        static let AccountLogin = "/players/me/"
    }
}