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
        
        defaults.setObject(user, forKey: APIManager.Constants.userIdDefault)
        defaults.setObject(password, forKey: APIManager.Constants.userPassDefault)
        

        taskWithMethod(APIManager.Methods.AccountLogin, method: "GET", HTTPBody: nil) { (result, error) in
            
            if error != nil {
                self.defaults.setObject(nil, forKey: APIManager.Constants.userIdDefault)
                self.defaults.setObject(nil, forKey: APIManager.Constants.userPassDefault)
                completion(response: "Error on signin, \(error?.localizedDescription)")
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
        // normal request process
        arenRequest("GET") { (response) in
            completion(response: response)
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
        
        taskWithMethod("\(APIManager.Methods.Arena)", method: method, HTTPBody: nil) { (result, error) in
            self.arenaRequestHandler(result, error: error, completion: { (players, errorplayers) in
                completion(players: players, error: errorplayers)
            })
        }

    }
    
    func arenaRequestHandler(result: AnyObject, error: NSError?, completion: (players:[User]!, error: String?) -> Void) -> Void {
        if error != nil{
            completion(players: nil, error: "\(error!.localizedDescription)")
            return
        }
        guard let jsObj = result as? NSData else {
            completion(players: nil, error: "Results error")
            return
        }
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(jsObj, options: .AllowFragments) as! [JsonObject]
            self.playersResponseHandler(json, completion: { (players) in
                completion(players: players, error: nil)
            })
            
        } catch{
            completion(players: nil, error: "Error serializing JSON for Active Players")
            
        }

    }
    
    
    // there's unknown error with this, it's always "message": "The other player has stepped out!",
    //    "status": 403, even if the player is there and all checked via soket too. 
    // handling wasn't finished well accordingly.
    func attackPLayer(id: Int) -> Void {
        attackPlayer(id) { (response) in
            NSNotificationCenter.defaultCenter().postNotificationName(APIManager.Notifications.AttackNotification, object: response)
        }
    }
    
    func attackPlayer(id: Int, completion: (response: String) -> Void){
        
        taskWithMethod("arena/attack/:id", method: "POST", HTTPBody: nil) { (result, error) in
            if error != nil{
                completion(response: "\(error!.localizedDescription)")
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! JsonObject
                guard let op = json["defender"] as? User, alias = op.alias else {
                    completion(response: "Error \(json["message"])")
                    return
                }
                completion(response: "You attacked \(alias) \(json["damage"])")
            } catch{
                completion(response: "Error serializing JSON for the attack")
                
            }
        }
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
    
    func playersResponseHandler(json: [JsonObject] ,completion: (players:[User]) -> Void){
        var players = [User]()
        for player in json {
            players.append(User(dictionary: player)!)
        }
        completion(players: players)
    }

    
    
    // MARK: -Me profile 
    
    func getMainProfile(completion: (playerProfile:AnyObject) -> Void) -> Void {
        
        taskWithMethod("/players/me", method: "GET", HTTPBody: nil) { (result, error) in
            
            do{
                let json = try NSJSONSerialization.JSONObjectWithData(result, options: .AllowFragments) as! JsonObject
                completion(playerProfile: User(dictionary: json)!)
                
            }catch {
                completion(playerProfile: "Error serializing JSON for login user")
            }

        }
        
    }
    
    
    // MARK: -Chat networking
    
    func getChatLogs(completion:(chatArray: [ChatLog]!, error: String?) -> Void) -> Void {
        
        taskWithMethod("\(APIManager.Methods.Chat)", method: "GET", HTTPBody: nil) { (result, error) in
            
            if error == nil{
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
    
    
    func chatSendMessage(message: String) -> Void {
        let body = "{\n  \"message\": \"Come at me, bro!\"\n}"
        taskWithMethod("\(APIManager.Methods.Chat)", method: "POST", HTTPBody: body) { (result, error) in
            print(error?.localizedDescription)
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
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
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