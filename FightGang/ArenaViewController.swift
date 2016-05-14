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
        
        
        // listen to socket
        // start live update from socket
        SocketIOManager.sharedInstance().arenaCheck { (results) in
            
            guard let results = results as? [JsonObject] else {
                print("Socket players error")
                return
            }
            var players = [User]()
            for res in results {
                players.append(User(dictionary: res)!)
            }
            
            self.arenaRespnseHandler(players)
        }
       

       
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // lay off socket and notifications
        SocketIOManager.sharedInstance().arenaoff()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: APIManager.Notifications.AttackNotification, object: nil)
        leavePlayersArena()
    }
    
    
    func postAlert(not: NSNotification) -> Void {
        dispatch_async(dispatch_get_main_queue()) {
            let error = not.object as! String
            self.showErrorAlert("Error", msg: error)
        }
    }
    
    deinit {
        SocketIOManager.sharedInstance().arenaoff()
    }
    
    
    
    
    @IBAction func joinArena(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            canAttack = false

            // off socket
            SocketIOManager.sharedInstance().arenaoffAttack()
            
           leavePlayersArena()
        }else {
            canAttack = true
            joinPlayersArena()
            
        }
        
    }
    
    func joinPlayersArena() -> Void {
        

        APIManager.sharedInstance().enteringArena { (players, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.arenaRespnseHandler(players)
                }else {
                    self.showErrorAlert("Error", msg: error!)
                }
            }
        }
    }
    
    func leavePlayersArena() -> Void  {
        // calling API
        APIManager.sharedInstance().leavingArena({ (players, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.arenaRespnseHandler(players)
                }else {
                    self.showErrorAlert("Error", msg: error!)
                }
                
            }
        })
    }

    func arenaRespnseHandler(players: [User]) -> Void {
        self.dataArray = players
        self.tableView.reloadData()
    }
    
    func getActivePlayers() -> Void {
        APIManager.sharedInstance().getActivePlayers({ (players, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.arenaRespnseHandler(players)
                }else {
                    self.showErrorAlert("Error", msg: error!)
                }
            }

            
        })
            
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
