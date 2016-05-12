////
////  Constants.swift
////  FightGang
////
////  Created by Abdulrhman  eaita on 5/11/16.
////  Copyright © 2016 Abdulrhman eaita. All rights reserved.
////

import Foundation



class DataService {
    // MARK: Shared Instance
    
    class func sharedInstance() -> DataService {
        struct Singleton {
            static var sharedInstance = DataService()
        }
        return Singleton.sharedInstance
    }
    
    var REF_BASE: String {
        get {
            return BASE_URL
        }
    }
    
    var API_KEY: String {
        get{
            return API_TOKEN
        }
    }
    
}