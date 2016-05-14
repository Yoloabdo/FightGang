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
            let loginString = NSString(format: "%@:%@", user, pass)
            let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
            return loginData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }
    }

    
    
    
   
   // MARK: -LOGIN function
    func  login(user: String, password: String, completion: (response:AnyObject) -> Void) {

        defaults.setObject(user, forKey: APIManager.Constants.userNameDefault)
        defaults.setObject(password, forKey: APIManager.Constants.userPassDefault)
        
        loginHelper(APIManager.Methods.AccountLogin, body: nil, method: "GET") { (response) in
            completion(response: response)
        }
    }

    // MARK: -Register function
    func register(user: String, password: String, alias: String, completion: (response:AnyObject) -> Void) {
        
        defaults.setObject(user, forKey: APIManager.Constants.userNameDefault)
        defaults.setObject(password, forKey: APIManager.Constants.userPassDefault)
        
        let body = "{\n  \"name\": \"\(user)\",\n  \"alias\": \"\(alias)\",\n  \"password\": \"\(password)\"\n}"
        
        loginHelper(APIManager.Methods.AccountRegister, body: body, method: "POST") { (response) in
            completion(response: response)
        }
    }
    
    private func loginHelper(url: String, body: String?, method: String, completion: (response:AnyObject) -> Void) {
        
        taskWithMethod(url, method: method, HTTPBody: body) { (result, error) in
            
            if error != nil {
                self.defaults.setObject(nil, forKey: APIManager.Constants.userNameDefault)
                self.defaults.setObject(nil, forKey: APIManager.Constants.userPassDefault)
                completion(response: "Error on sign/register, \(error!.localizedFailureReason!)")
            }else{
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! JsonObject
                    print("succeful login/ register")
                    let loginUser = User(dictionary: json)!
                    self.defaults.setObject(loginUser.id, forKey: APIManager.Constants.userIdDefault)
                    completion(response: loginUser)
                    
                }catch {
                    completion(response: "Error serializing JSON for login user")
                }
            }
            
            
        }

    }

    
    // MARK: -Arena networking
    
    func getActivePlayers(completion: (players:[User]!, error: String?) -> Void) {
        // normal request process
        arenaEntrance("GET") { (players, error) in
            completion(players: players, error: error)
        }

    }
    
    
    func  enteringArena(completion: (players:[User]!, error: String?) -> Void) -> Void {
        arenaEntrance("POST") { (players, error) in
            completion(players: players, error: error)
        }
    }
    
    
    func  leavingArena(completion: (players:[User]!, error: String?) -> Void) -> Void {
        arenaEntrance("DELETE") { (players, error) in
            completion(players: players, error: error)
        }
    }
    
    private func arenaEntrance(method: String, completion: (players:[User]!, error: String?) -> Void) {
        
        taskWithMethod(APIManager.Methods.Arena, method: method, HTTPBody: nil) { (result, error) in
            self.arenaResponseHandler(result, error: error, completion: { (players, errorplayers) in
                completion(players: players, error: errorplayers)
            })
        }

    }
    
    func arenaResponseHandler(result: AnyObject, error: NSError?, completion: (players:[User]!, error: String?) -> Void) -> Void {
        if error != nil{
            completion(players: nil, error: "\(error!.localizedFailureReason!)")
            return
        }
        guard let jsObj = result as? NSData else {
            completion(players: nil, error: "Results error")
            return
        }
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(jsObj, options: .AllowFragments) as! [JsonObject]
            var players = [User]()
            for player in json {
                players.append(User(dictionary: player)!)
            }
            completion(players: players, error: nil)
            
        } catch{
            completion(players: nil, error: "Error serializing JSON for Active Players")
            
        }

    }
    
    

    
    // Error solved, works well now!
    func attackPLayer(id: Int) -> Void {
        attackPlayer(id) { _ in
//            print(response)
        }
    }
    
    private func attackPlayer(id: Int, completion: (response: String) -> Void){
        
        taskWithMethod(APIManager.Methods.Attack + "\(id)", method: "POST", HTTPBody: nil) { (result, error) in
            if error != nil{
                completion(response: "\(error!.localizedFailureReason!)")
                return
            }
            completion(response: "Attack is okay")
        }
    }
    
    
    
    // MARK: -Me profile 
    
    func getMainProfile(completion: (playerProfile:AnyObject) -> Void) -> Void {
        
        taskWithMethod(APIManager.Methods.AccountLogin, method: "GET", HTTPBody: nil) { (result, error) in
            if error != nil {
                completion(playerProfile: error!.localizedFailureReason!)
            }else{
                
                do{
                    let json = try NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! JsonObject
                    completion(playerProfile: User(dictionary: json)!)
                    
                }catch {
                    completion(playerProfile: "Error serializing JSON for login user")
                }

            }
        }
        
    }
    
    
    // MARK: -Chat networking
    
    func getChatLogs(completion:(chatArray: [ChatLog]!, error: String?) -> Void) -> Void {
        
        taskWithMethod("\(APIManager.Methods.Chat)", method: "GET", HTTPBody: nil) { (result, error) in
            if error != nil {
                completion(chatArray: nil, error: error!.localizedFailureReason!)
            }else{
                self.chatResponseHandler(result, completion: { (chatArray, error) in
                    completion(chatArray: chatArray, error: error)
                })
            }
        }

    }
    
    func chatResponseHandler(JsonData: NSData, completion:(chatArray: [ChatLog]!, error: String?) -> Void) -> Void {
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(JsonData, options: .AllowFragments) as! [JsonObject]
            var chatLogs = [ChatLog]()
            for chat in json {
                chatLogs.append(ChatLog(obj: chat))
            }
            completion(chatArray: chatLogs, error: nil)
            
        }catch {
            completion(chatArray: nil, error:  "Error serializing JSON for login user")
        }

    }
    
    // this too yeilds error from API no matter what i do, dunno where's the problem?? still lacks implementation
    func chatSendMessage(message: String, completion: (message: String) -> Void) -> Void {
        let body = "{\n  \"message\": \"Come at me, bro!\"\n}"
        
        taskWithMethod(APIManager.Methods.Chat, method: "POST", HTTPBody: body) { (result, error) in
            completion(message: error!.localizedFailureReason!)
        }
    }
    

    

    func taskWithMethod(apiURL: String, method: String, HTTPBody: String?, completionHandlerForPOST: (result: NSData!, error: NSError?) -> Void) -> Void {
        
        /* 1. Set the URL */
        let url = NSURL(string: APIManager.Constants.BaseURL+apiURL)!
        /* 2/3. Build the URL, Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = method
        
        if let body = HTTPBody {
            request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        }
  
        request.addValue("Basic \(Auth!)", forHTTPHeaderField: "Authorization")
        request.addValue(APIManager.Constants.API_KEY, forHTTPHeaderField: "X-Api-Token")

        let session = NSURLSession.sharedSession()

        /* 4. Make the request */
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            // layOFFIndicator
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false

            func sendError(error: String) {
                var userInfo = [NSLocalizedDescriptionKey : error]
                
                do {
                    let errorMessage = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? JsonObject
                    userInfo[NSLocalizedFailureReasonErrorKey] = errorMessage!["message"] as? String
                    completionHandlerForPOST(result: nil, error: NSError(domain: "taskWithMethod", code: 1, userInfo: userInfo))
                }catch{
                    completionHandlerForPOST(result: nil, error: NSError(domain: "taskWithMethod", code: 1, userInfo: userInfo))
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            completionHandlerForPOST(result: data, error: nil)
            
            
        }
        
        /* 7. Start the request */
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