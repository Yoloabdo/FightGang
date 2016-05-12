//
//  ViewController.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/11/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    

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
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if NSUserDefaults.standardUserDefaults().valueForKey(APIManager.Constants.userNameDefault) != nil {
            loginBtn()
        }
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
    
    
    @IBAction func loginBtn() {
        // resign responder
        passTextField.resignFirstResponder()
        userNameTextField.resignFirstResponder()
        
        // activte indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        
        // calling API
        APIManager.sharedInstance().login(userNameTextField.text!, password: passTextField.text!) { (response) in
            self.responseHandling(response)
            
        }

        
    }
    
    
    func responseHandling(response: AnyObject) -> Void {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        guard response is User else {
            self.showErrorAlert("Erorr", msg: response as! String)
            return
        }
        self.performSegueWithIdentifier(StoryBoard.SegueId, sender: nil)
    }
    
    @IBAction func registerBtn(sender: UIButton) {
        // saving user, pass to NSUSERDefaults
        defaults.setObject(userNameTextField.text!, forKey: APIManager.Constants.userNameDefault)
        defaults.setObject(passTextField.text!, forKey: APIManager.Constants.userPassDefault)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        // calling API
        APIManager.sharedInstance().register(userNameTextField.text!, password: passTextField.text!, alias: aliasTextField.text!){ (response) in
            self.responseHandling(response)
        }
        
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

