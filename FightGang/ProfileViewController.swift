//
//  ProfileViewController.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/13/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    var userProfile: User!{
        didSet{
            updateUI()
        }
    }

    @IBOutlet weak var userAlias: UILabel!
    @IBOutlet weak var userLevel: UILabel!
    @IBOutlet weak var experience: UILabel!
    @IBOutlet weak var stamina: UILabel!
    @IBOutlet weak var totalHits: UILabel!
    

  
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        APIManager.sharedInstance().getMainProfile { (playerProfile) in
            dispatch_async(dispatch_get_main_queue()) {
                self.userProfile = playerProfile as! User
            }
        }
        
    
        SocketIOManager.sharedInstance().playersHeal { (healInfo) in
            dispatch_async(dispatch_get_main_queue()) {
                let info = healInfo as! JsonObject
                self.stamina?.text = "\(info["16"]!)"
            }
        }
        
    }
    
    func updateUI() -> Void {
        userAlias?.text = userProfile.alias
        userLevel?.text = "\(userProfile.level!)"
        experience?.text = "\(userProfile.experience)/\(userProfile.expNext)"
        stamina?.text = "\(userProfile.stamina!)"
        totalHits?.text = "\(userProfile.hits!)"
        
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SocketIOManager.sharedInstance().playerHealOff()
    }

}
