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

    
    @IBOutlet weak var userNameTextField: UITextField!

    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var aliasTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton! {
        didSet{
            registerButton.enabled = false
        }
    }
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    
    @IBAction func loginBtn(sender: UIButton) {
        
    }
    
    @IBAction func registerBtn(sender: UIButton) {
        register(userNameTextField.text!, pass: passTextField.text!, alias: aliasTextField.text!)
        
    }
    
    
    @IBAction func enableBtns() -> Void {
        if checkLoginTextFields() {
            loginButton.enabled = true
        }
        if checkRegisterTextFields() {
            registerButton.enabled = true
        }
    }
    
    func checkLoginTextFields() -> Bool {
        guard let user = userNameTextField.text else {
            return false
        }
        guard let pass = passTextField.text else {
            return false
        }
        
        
        if user.isEmpty && pass.isEmpty{
            return false
        }
        return true
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
    
    func register(user: String, pass: String, alias: String) -> Void {
        let url = NSURL(string: "\(BASE_URL)/players")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(API_TOKEN, forHTTPHeaderField: "X-Api-Token")
        request.HTTPBody = "{\n  \"name\": \"\(user)\",\n  \"alias\": \"\(alias)\",\n  \"password\": \"\(pass)\"\n}".dataUsingEncoding(NSUTF8StringEncoding);
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let response = response, data = data {
                print(response)
                print(String(data: data, encoding: NSUTF8StringEncoding))
            } else {
                print(error)
            }
        }
        
        task.resume()
    }

}


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    

}

