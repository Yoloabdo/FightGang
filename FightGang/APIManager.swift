////
////  Constants.swift
////  FightGang
////
////  Created by Abdulrhman  eaita on 5/11/16.
////  Copyright © 2016 Abdulrhman eaita. All rights reserved.
////

import UIKit





class APIManager: NSObject {
   
    let defaults = NSUserDefaults.standardUserDefaults()

    

    var username: String? {
        get {
           return defaults.stringForKey(APIManager.Constants.userNameDefault) ?? nil
        }
    }
    
    var passWord: String? {
        get {
            return defaults.stringForKey(APIManager.Constants.userPassDefault) ?? nil
        }
    }
    
    
    
    private func networkRequest(request: NSURLRequest, completion: AnyObject -> Void)
    {
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let response = response, data = data {
                // check login status via response code
                var json: Dictionary<String, AnyObject>?
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? Dictionary<String, AnyObject>
                    if let res = response as? NSHTTPURLResponse where res.statusCode == 200 || res.statusCode == 201{
                        
                        // Creating user from results
                        let userObj = User(dictionary: json!)
                        dispatch_async(dispatch_get_main_queue(), {() in
                            print("User logged in succefully")
                            completion(userObj)
                            
                        })
                        return
                    }else {
                        dispatch_async(dispatch_get_main_queue(), {() in
                            guard let message = json!["message"] as? String else {
                                completion(json!)
                                return
                            }
                            completion(message)
                            
                        })
                    }}
                    
                catch {
                    print(response)
                    print(String(data: data, encoding: NSUTF8StringEncoding))
                    return
                }
            }
                
                
            else {
                completion(error!)
            }
        }
        task.resume()
        
    }
    
    func  login(completion: (response:AnyObject) -> Void) {
        guard let user = username, let pass = passWord else {
            print("couldn't get user or password")
            return
        }
        let url = NSURL(string: APIManager.Constants.BaseURL + APIManager.Methods.AccountLogin)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")
        
        
        let loginString = NSString(format: "%@:%@", user, pass)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        
        
        networkRequest(request) { (response) in
            return completion(response: response)
        }
        
        
    }


    
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> APIManager {
        struct Singleton {
            static var sharedInstance = APIManager()
        }
        return Singleton.sharedInstance
    }
    
}