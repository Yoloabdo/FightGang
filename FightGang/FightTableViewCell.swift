//
//  FightTableViewCell.swift
//  FightGang
//
//  Created by Abdulrhman  eaita on 5/12/16.
//  Copyright © 2016 Abdulrhman eaita. All rights reserved.
//

import UIKit

class FightTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var playerStaminaLabel: UILabel!
    @IBOutlet weak var playerLevelLabel: UILabel!
    @IBOutlet weak var staminaProgressView: UIProgressView!
    @IBOutlet weak var attackBtn: UIButton!

    
    
    var cellUser: User! {
        didSet{
            updateUI()
        }
    }
    
    var canAttack = false

    let defaults = NSUserDefaults.standardUserDefaults()
    
    func updateUI() -> Void {
        if defaults.integerForKey(APIManager.Constants.userIdDefault) == cellUser.id {
            playerNameLabel?.text = "\(cellUser.alias!) (Me)"
            attackBtn.hidden = true
            
        }else {
            playerNameLabel?.text = cellUser.alias!
            attackBtn.hidden = false
        }
        playerStaminaLabel?.text = "Stamina: \(cellUser.stamina!)"
        playerLevelLabel?.text = "Level: \(cellUser.level!)"
        staminaProgressView.progress = Float(Double(cellUser.stamina!)/1000)
        attackBtn.enabled = canAttack
    }
    @IBAction func attackUser(sender: UIButton) {
        if canAttack {
            APIManager.sharedInstance().attackPLayer(cellUser.id!)
        }
        
    }
    
    
}
