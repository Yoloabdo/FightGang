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
        
//        checking if the user has old credintials.
        guard let user = defaults.stringForKey(APIManager.Constants.userNameDefault), pass = defaults.stringForKey(APIManager.Constants.userPassDefault) else {
            print("No previous login")
            return
        }
        login(user, pass: pass)
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidLoad()
     
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
        
        // calling API
        login(userNameTextField.text!, pass: passTextField.text!)
        
    }
    
    func login(user: String, pass: String){
        
        // calling API
        APIManager.sharedInstance().login(user, password: pass) { (response) in
            dispatch_async(dispatch_get_main_queue()) {
                self.responseHandling(response)

            }
        }

    }
    
    
    func responseHandling(response: AnyObject) -> Void {
        guard response is User else {
            self.showErrorAlert("Erorr", msg: response as! String)
            return
        }
        self.performSegueWithIdentifier(StoryBoard.SegueId, sender: nil)
    }
    
    @IBAction func registerBtn(sender: UIButton) {
        
        
        // calling API
        APIManager.sharedInstance().register(userNameTextField.text!, password: passTextField.text!, alias: aliasTextField.text!){ (response) in
            dispatch_async(dispatch_get_main_queue()) {
                self.responseHandling(response)
            }
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
    
    func animateTextField(textField: UITextField, up: Bool, len: CGFloat) {
        let movementDistance:CGFloat = -len
        let movementDuration: Double = 0.3
        
        var movement:CGFloat = 0
        if up {
            movement = movementDistance
        }
        else {
            movement = -movementDistance
        }
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        UIView.commitAnimations()
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == aliasTextField {
            animateTextField(aliasTextField, up: true, len: 50)
        }
        return true
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == aliasTextField {
            animateTextField(aliasTextField, up: false, len: 50)
        }
    }


}

