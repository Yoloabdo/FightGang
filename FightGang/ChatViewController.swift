//
//  ChatViewController.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/13/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        APIManager.sharedInstance().getChatLogs { logs, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.handleChatResponse(logs)
                }else{
                    self.showErrorAlert("Error", msg: error!)
                }
            }
            
            
        }
        // keyboard notifications UX for messageTextField
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotfication), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardNotfication), name: UIKeyboardWillHideNotification, object: nil)
        
        // Socket for chat messages. 
        
        SocketIOManager.sharedInstance().chatUpdates { (messages) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            dispatch_async(dispatch_get_main_queue()) {
                self.handleChatResponse(messages)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
        }
    }
    
    func handleChatResponse(logs: AnyObject) {
        guard let chatlogs = logs as? [ChatLog] else {
            self.showErrorAlert("Error Loading", msg: logs as! String)
            return
        }
        self.chatData = chatlogs
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: self.view.window)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: self.view.window)
        
        SocketIOManager.sharedInstance().chatUpdatesOff()
    }
    
    // handles view when keyboard appears or disaapears
    var movedView = true
    func keyboardNotfication(notification: NSNotification) {
        guard let keyboardHeight = (notification.userInfo! as NSDictionary).objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue.size.height else {
            return
        }
        if movedView {
            animateTextField(messageTextField, up: movedView, len: keyboardHeight)
            view.layoutIfNeeded()
            movedView = false
        }else {
            animateTextField(messageTextField, up: movedView, len: keyboardHeight)
            view.layoutIfNeeded()
            movedView = true
        }
        
    }

    
    @IBOutlet weak var chatTextField: UITextField!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func sendMessage(sender: UIButton) {
        APIManager.sharedInstance().chatSendMessage(messageTextField.text!)
    }
    
    var chatData = [ChatLog]()
    
    struct StoryBoard {
        static let CellId = "ChatCell"
    }
    
    
    // MARK: -UITable
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatData.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.CellId, forIndexPath: indexPath)
        let log = chatData[indexPath.row]
        cell.textLabel?.text = log.message
        cell.detailTextLabel?.text = log.sender
        return cell
    }

    
    
    func showErrorAlert(title: String, msg: String) -> Void {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}


extension ChatViewController: UITextFieldDelegate {
    
    
    // hitting next or done in keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        messageTextField.resignFirstResponder()
        return true;
        
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
    
    
}

