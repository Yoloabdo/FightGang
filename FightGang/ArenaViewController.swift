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
    @IBOutlet weak var arenaSegmentController: UISegmentedControl!

 
    var canAttack = false
    
    var dataArray = [User]()
    var dataCount = 0
    
    struct StoryBoard {
        static let CellId = "Cell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //load data
        getActivePlayers()
    
       
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
        
        
        SocketIOManager.sharedInstance().arenaOnAttack { (attackRes) in
            let res = attackRes as! JsonObject
            guard let op = res["defender"] as? JsonObject, damage = res["damage"] as? Int else {
                self.showErrorAlert("Error", msg:"Error parsing JSON for the attack")
                return
            }
            self.showErrorAlert("You attacked \(User(dictionary: op)!.alias!) for \(damage) damage.", msg: "")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        canAttack = false
        
        arenaSegmentController.selectedSegmentIndex = 0
        // lay off socket and notifications
        SocketIOManager.sharedInstance().arenaoff()

        leavePlayersArena()
        
    }
    
    deinit {
        SocketIOManager.sharedInstance().arenaoff()
    }
    
    
    
    
    @IBAction func joinArena(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            
           leavePlayersArena()
        }else {
            joinPlayersArena()
            
        }
        
    }
    
    func joinPlayersArena() -> Void {
        

        APIManager.sharedInstance().enteringArena { (players, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if error == nil {
                    self.canAttack = true
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
                    self.canAttack = false
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
