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

        // listen to notification .
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(getActivePlayers), name: SocketIOManager.Constants.notficationName, object: nil)
        
//         load data 
        getActivePlayers()
        
       
    }
    
    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: SocketIOManager.Constants.notficationName, object: nil)
    }
    
    
    
    
    @IBAction func joinArena(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            canAttack = false
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

}
