////
////  Constants.swift
////  FightGang
////
////  Created by Abdulrhman  eaita on 5/11/16.
////  Copyright © 2016 Abdulrhman eaita. All rights reserved.
////

import UIKit


typealias JsonObject = Dictionary<String, AnyObject>


class APIManager: NSObject {
   
    let defaults = NSUserDefaults.standardUserDefaults()

    

    var userName: String? {
        get {
           return defaults.stringForKey(APIManager.Constants.userNameDefault) ?? nil
        }
    }
    
    var passWord: String? {
        get {
            return defaults.stringForKey(APIManager.Constants.userPassDefault) ?? nil
        }
    }
    
    var Auth: String? {
        get {
            guard let user = userName, let pass = passWord else {
                print("couldn't get user or password")
                return nil
            }
            return authrization(user, pass: pass)
        }
    }

    
    
    func authrization(user: String, pass: String) -> String {
        let loginString = NSString(format: "%@:%@", user, pass)
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        return loginData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
    }
    
    
    
   
   // MARK: -LOGIN function
    func  login(user: String?, password: String?, completion: (response:AnyObject) -> Void) {
        
        var user = user, password = password
        
        let url = NSURL(string: APIManager.Constants.BaseURL + APIManager.Methods.AccountLogin)!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")
        
        // check nullability, get them from defaults if exists
        if user == nil {
            user = userName
            password = passWord
        }
        
        request.setValue("Basic \(authrization(user!, pass: password!))", forHTTPHeaderField: "Authorization")
        
        
        networkRequest(request) { (data, code) in
            self.loginRequestHandling(user!, pass: password!, data: data, code: code, completion: { (response) in
                completion(response: response)
            })
        }
        
        
    }
   

    // MARK: -Register function
    func register(user: String, password: String, alias: String, completion: (response:AnyObject) -> Void) {
        
        let url = NSURL(string: APIManager.Constants.BaseURL + APIManager.Methods.AccountRegister)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")
        request.HTTPBody = "{\n  \"name\": \"\(user)\",\n  \"alias\": \"\(alias)\",\n  \"password\": \"\(password)\"\n}".dataUsingEncoding(NSUTF8StringEncoding)
        
        
        networkRequest(request) { (data, code) in
            self.loginRequestHandling(user, pass: password, data: data, code: code, completion: { (response) in
                completion(response: response)
                
            })
        }
    }
    
    // login/register helper function
    func  loginRequestHandling(user: String, pass: String, data: NSData, code: Int,completion: (response:AnyObject) -> Void) -> Void {
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! JsonObject
            if code == 200 {
                print("succeful login/ register")
                let loginUser = User(dictionary: json)!
                defaults.setObject(loginUser.id, forKey: APIManager.Constants.userIdDefault)
                self.defaults.setObject(user, forKey: APIManager.Constants.userNameDefault)
                self.defaults.setObject(pass, forKey: APIManager.Constants.userPassDefault)
                
                completion(response: loginUser)
                return
            }else {
                print("Error login/ register")
                completion(response: json["message"]!)
                return
            }
        }catch {
            completion(response: "Error serializing JSON for login user")
        }
        
        
    }
    
    // MARK: -Arena networking
    
    func getActivePlayers(completion: (response:AnyObject) -> Void) {
    
        arenRequest("GET") { (response) in
            completion(response: response)
        }

    }
    
    func  enteringArena(completion: (response:AnyObject) -> Void) -> Void {
        arenRequest("POST") { (response) in
            completion(response: response)
        }
        
    }
    func arenRequest(HttpMethod: String, completion: (response:AnyObject) -> Void) -> Void {
        let url = NSURL(string: "\(APIManager.Constants.BaseURL)\(APIManager.Methods.Arena)")!
        let request = NSMutableURLRequest(URL: url)
        if HttpMethod == "POST" {
            request.HTTPMethod = "POST"
        }
        request.setValue("Basic \(Auth!)", forHTTPHeaderField: "Authorization")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")
        
        
        
        networkRequest(request) { (data, code) in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [JsonObject]
                if code == 200 {
                    var players = [User]()
                    for player in json {
                        players.append(User(dictionary: player)!)
                    }
                    completion(response: players)
                }else{
                    completion(response: "Error loading Active Players")
                }
            } catch{
                completion(response: "Error serializing JSON for Active Players")
                
            }
            
            
        }
    }


    // MARK: -NetWork request 
    private func networkRequest(request: NSURLRequest, completion:(data:NSData, responseCode: Int) -> Void)
    {
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let response = response as? NSHTTPURLResponse, data = data {
                // check login status via response code
                dispatch_async(dispatch_get_main_queue()) {
                    completion(data: data, responseCode: response.statusCode)
                }
            }
                
            else {
                print(error)
                return
            }
        }
        task.resume()
        
        
    }


    
    
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> APIManager {
        struct Singleton {
            static var sharedInstance = APIManager()
        }
        return Singleton.sharedInstance
    }
    
}