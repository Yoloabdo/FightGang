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
        
//         load data 
        APIManager.sharedInstance().getActivePlayers { (response) in
            let players = response as! [User]
            self.dataArray = players
            self.tableView.reloadData()
        }
        
    }
    @IBAction func joinArena(sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            
        }else {
            canAttack = true
            joinArea()
        }
        
    }
    
    func joinArea() -> Void {
        
        
    }

    
    
    
    
    // MARK: -TabelView handling
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StoryBoard.CellId, forIndexPath: indexPath) as! FightTableViewCell
        
        cell.cellUser = dataArray[indexPath.row]
        
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
