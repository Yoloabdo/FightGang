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

    
    
    var cellUser: User! {
        didSet{
            updateUI()
        }
    }

    
    func updateUI() -> Void {
        playerNameLabel?.text = cellUser.alias!
        playerStaminaLabel?.text = "Stamina: \(cellUser.stamina!)"
        playerLevelLabel?.text = "Level: \(cellUser.level!)"
        staminaProgressView.progress = Float(Double(cellUser.stamina!)/1000)
    }
}
