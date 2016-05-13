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
        APIManager.sharedInstance().getChatLogs { logs in
            guard let chatlogs = logs as? [ChatLog] else {
                self.showErrorAlert("Error Loading", msg: logs as! String)
                return
            }
            self.chatData = chatlogs
            self.tableView.reloadData()
            
        }
    }
    @IBOutlet weak var chatTextField: UITextField!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessage(sender: UIButton) {
        
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
