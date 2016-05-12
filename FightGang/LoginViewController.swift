//
//  ViewController.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/11/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    

    let BASE_URL = "https://fightgang.herokuapp.com/api"
    
    let API_TOKEN = "p0x0XirrQV66w18372t8l91WCklUqq4K657tT1A06b6m10TuG6n6894S2IHFH3YP"
    
    let defaults = NSUserDefaults.standardUserDefaults()

    
    @IBOutlet weak var userNameTextField: UITextField!

    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var aliasTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton! {
        didSet{
            disableBtn(registerButton)
        }
    }
    @IBOutlet weak var loginButton: UIButton!{
        didSet{
            disableBtn(loginButton)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func enableBtn(btn: UIButton) -> Void {
        btn.enabled = true
        borderlayer(btn.layer, color: UIColor.blueColor())

    }
    
    func disableBtn(btn: UIButton) -> Void {
        btn.enabled = false
        borderlayer(btn.layer, color: UIColor.grayColor())

    }

    func borderlayer(layer: CALayer, color: UIColor) -> Void {
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = color.CGColor
    }
    
    
    @IBAction func loginBtn(sender: UIButton) {
        // resign responder
        passTextField.resignFirstResponder()
        userNameTextField.resignFirstResponder()
        
        // saving user, pass to NSUSERDefaults
        defaults.setObject(userNameTextField.text!, forKey: APIManager.Constants.userNameDefault)
        defaults.setObject(passTextField.text!, forKey: APIManager.Constants.userPassDefault)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        APIManager.sharedInstance().login { (response) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            guard let _ = response as? User else {
                self.showErrorAlert("Erorr", msg: response as! String)
                return
            }
            self.performSegueWithIdentifier(StoryBoard.SegueId, sender: nil)

            
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false

        
    }
    
    @IBAction func registerBtn(sender: UIButton) {
        register(userNameTextField.text!, pass: passTextField.text!, alias: aliasTextField.text!)
        
    }
    
    
    @IBAction func enableBtns() -> Void {
        if checkLoginTextFields() {
            enableBtn(loginButton)
        }else{
            disableBtn(loginButton)
        }
        if checkRegisterTextFields() {
            enableBtn(registerButton)
        }else {
            disableBtn(registerButton)

        }
    }
    
    func checkLoginTextFields() -> Bool {
        guard let user = userNameTextField.text else {
            return false
        }
        guard let pass = passTextField.text else {
            return false
        }
        
        
        if !user.isEmpty && !pass.isEmpty{
            return true
        }
        return false
    }
    
    func checkRegisterTextFields() -> Bool {
        guard let alias = aliasTextField.text else {
            return false
        }
        if alias.isEmpty {
            return false
        }else {
            return checkLoginTextFields()
        }
    }
    
    struct StoryBoard {
        static let SegueId = "login"
    }
    
    // register function.
    func register(user: String, pass: String, alias: String) {
        let url = NSURL(string: "\(BASE_URL)/players")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(API_TOKEN, forHTTPHeaderField: "X-Api-Token")
        request.HTTPBody = "{\n  \"name\": \"\(user)\",\n  \"alias\": \"\(alias)\",\n  \"password\": \"\(pass)\"\n}".dataUsingEncoding(NSUTF8StringEncoding)
        
//        networkRequest(request)
    }

//    func  login(user: String, pass: String) {
//        let url = NSURL(string: "\(BASE_URL)/players/me/")!
//        
//        let request = NSMutableURLRequest(URL: url)
//        request.HTTPMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(API_TOKEN, forHTTPHeaderField: "X-Api-Token")
//        
//        
//        let loginString = NSString(format: "%@:%@", user, pass)
//        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
//        let base64LoginString = loginData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//        
//        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//        APIManager.sharedInstance().networkRequest(request) { (response) in
//            
//        }
//        
//        
////        networkRequest(request)
//
//    }
    
        
    func showErrorAlert(title: String, msg: String) -> Void {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }


}


extension LoginViewController: UITextFieldDelegate {
    
    
    // hitting next or done in keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == userNameTextField {
            
            passTextField.becomeFirstResponder()
            return true
            
        }else {
            
            textField.resignFirstResponder()
            
            return true;
        }
       
    }
    
    // if user touched any part of the screen, lay off the keyboard.
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        userNameTextField.resignFirstResponder()
        passTextField.resignFirstResponder()
        aliasTextField.resignFirstResponder()
    }


}

