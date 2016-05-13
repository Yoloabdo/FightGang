//
//  ArenaViewController.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/12/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import UIKit

class ArenaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

 
    var canAttack = false
    
    var dataArray = [User]()
    var dataCount = 0
    
    struct StoryBoard {
        static let CellId = "Cell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // listen to notification 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(postAlert), name: APIManager.Notifications.AttackNotification, object: nil)
        
//         load data 
        getActivePlayers()
        
        
        // listen to socket attacks
        SocketIOManager.sharedInstance().arenaOnAttack { (results) in
            print("Socket attack")
            APIManager.sharedInstance().arenaAttackJsonHandler(results as! JsonObject, completion: { (jsonParsing) in
                self.showErrorAlert("", msg: results as! String)
            })
            
        }

       
    }
    
    func postAlert(not: NSNotification) -> Void {
        let error = not.object as! String
        showErrorAlert("Error", msg: error)
    }
    
    deinit {
        SocketIOManager.sharedInstance().arenaoff()
    }
    
    
    
    
    @IBAction func joinArena(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            canAttack = false
            // indicator 

            // off socket
            SocketIOManager.sharedInstance().arenaoffAttack()
            
            // calling API
            APIManager.sharedInstance().leavingArena({ (response) in
                print("Left arena")
                self.arenaRespnseHandler(response)
            })
            
        }else {
            canAttack = true
            joinArenaPlayers()
            
        }
        
    }
    
    func joinArenaPlayers() -> Void {
        

        APIManager.sharedInstance().enteringArena { (response) in
            print("entered arena")
            self.arenaRespnseHandler(response)
            
        }
    }

    func arenaRespnseHandler(data: AnyObject) -> Void {
        let players = data as! [User]
        self.dataArray = players
        self.tableView.reloadData()

    }
    
    func getActivePlayers() -> Void {
        print("Reloaded")
        APIManager.sharedInstance().getActivePlayers { (response) in
            self.arenaRespnseHandler(response)
        }
    }
    
    
    
    
    // MARK: -TabelView handling
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.CellId, forIndexPath: indexPath) as! FightTableViewCell
        
        cell.cellUser = dataArray[indexPath.row]
        cell.canAttack = canAttack
        return cell
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showErrorAlert(title: String, msg: String) -> Void {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }


}
