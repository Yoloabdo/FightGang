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
    
    // MARK: -Helper vars
   
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
            if code == 200 || code == 201{
                print("succeful login/ register")
                let loginUser = User(dictionary: json)!
                self.defaults.setObject(loginUser.id, forKey: APIManager.Constants.userIdDefault)
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
    
        // start live update from socket
        SocketIOManager.sharedInstance().arenaCheck { (results) in
            self.playersResponseHandler(results as! [JsonObject], completion: { (players) in
                completion(response: players)
            })
        }
        
        // normal request process
        arenRequest("GET") { (response) in
            completion(response: response)
        }

    }
    
    
    func  enteringArena(completion: (response:AnyObject) -> Void) -> Void {
        arenRequest("POST") { (response) in
            completion(response: response)
        }
        
    }
    
    
    func  leavingArena(completion: (response:AnyObject) -> Void) -> Void {
        
        arenRequest("DELETE") { (response) in
            completion(response: response)
        }

    }
    
    // there's unknown error with this, it's always "message": "The other player has stepped out!",
    //    "status": 403, even if the player is there and all checked via soket too. 
    // handling wasn't finished well accordingly.
    func attackPlayer(id: Int, completion: (response:AnyObject) -> Void){
        let url = NSURL(string: "\(APIManager.Constants.BaseURL)\(APIManager.Methods.Arena)/attack/:\(id)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.setValue("Basic \(Auth!)", forHTTPHeaderField: "Authorization")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")
        
        networkRequest(request) { (data, responseCode) in
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! JsonObject
                if responseCode == 200 {
                    self.arenaAttackJsonHandler(json, completion: { (jsonParsing) in
                        completion(response: jsonParsing)
                    })
                }else{
                    let errorMessage = "\(json["message"] as! String)"
                    completion(response: errorMessage)
                    NSNotificationCenter.defaultCenter().postNotificationName(APIManager.Notifications.AttackNotification, object: errorMessage)
                }
            } catch{
                print(responseCode)
                completion(response: "Error serializing JSON for the attack")
                
            }

        }

    }
    
    
    func arenaAttackJsonHandler(json: JsonObject, completion: (jsonParsing:AnyObject) -> Void) -> Void {
        guard let op = json["defender"] as? User, alias = op.alias else {
            print("Error loading oponnent alias")
            return
        }
        completion(jsonParsing: "You attacked \(alias) \(json["damage"])")
       
    }
    
    func arenRequest(HttpMethod: String, completion: (response:AnyObject) -> Void) -> Void {
        let url = NSURL(string: "\(APIManager.Constants.BaseURL)\(APIManager.Methods.Arena)")!
        let request = NSMutableURLRequest(URL: url)
        if HttpMethod != "GET" {
            request.HTTPMethod = HttpMethod
        }
        request.setValue("Basic \(Auth!)", forHTTPHeaderField: "Authorization")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")
        
        
        
        networkRequest(request) { (data, code) in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [JsonObject]
                if code == 200 {
                    self.playersResponseHandler(json, completion: { (players) in
                        completion(response: players)
                    })
                }else{
                    completion(response: "Error loading Active Players")
                }
            } catch{
                completion(response: "Error serializing JSON for Active Players")
                
            }
            
            
        }
    }
    
    func playersResponseHandler(json: [JsonObject] ,completion: (players:AnyObject) -> Void){
        var players = [User]()
        for player in json {
            players.append(User(dictionary: player)!)
        }
        completion(players: players)
    }

    
    
    // MARK: -Me profile 
    
    func getMainProfile(completion: (playerProfile:AnyObject) -> Void) -> Void {
        let url = NSURL(string: "\(APIManager.Constants.BaseURL)/players/me")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("Basic \(Auth!)", forHTTPHeaderField: "Authorization")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")
        
        networkRequest(request) { (data, responseCode) in
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! JsonObject
                    completion(playerProfile: User(dictionary: json)!)
                
            }catch {
                completion(playerProfile: "Error serializing JSON for login user")
            }

        }
    }
    
    
    // MARK: -Chat networking
    
    func getChatLogs(completion:(chatArray: AnyObject) -> Void) -> Void {
        let url = NSURL(string: "\(APIManager.Constants.BaseURL)\(APIManager.Methods.Chat)")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("Basic \(Auth!)", forHTTPHeaderField: "Authorization")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")
        
        networkRequest(request) { (data, responseCode) in
            
            self.chatResponseHandler(data, code: responseCode, completion: { (chatArray) in
                completion(chatArray: chatArray)
            })
        }
    }
    
    func chatResponseHandler(JsonData: NSData, code: Int, completion:(chatArray: AnyObject) -> Void) -> Void {
        if code != 200 {
            completion(chatArray: "Network error \(code)")
            return
        }
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(JsonData, options: .AllowFragments) as! [JsonObject]
            var chatLogs = [ChatLog]()
            for chat in json {
                chatLogs.append(ChatLog(obj: chat))
            }
            completion(chatArray: chatLogs)
            
        }catch {
            completion(chatArray: "Error serializing JSON for login user")
        }

    }
    
    

    // MARK: -NetWork request
    private func networkRequest(request: NSURLRequest, completion:(data:NSData, responseCode: Int) -> Void)
    {
        // loading network indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let response = response as? NSHTTPURLResponse, data = data {
                // check login status via response code
                dispatch_async(dispatch_get_main_queue()) {
                    // lay off indicator
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    // return results
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