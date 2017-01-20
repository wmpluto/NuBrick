//
//  DeviceLinkCell.swift
//  NuBrick
//
//  Created by Eve on 20/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit

class DeviceLinkCell: UITableViewCell {

    
    @IBOutlet weak var view: UIImageView!
    @IBOutlet weak var checkBuzzer: UIButton!
    @IBOutlet weak var checkLed: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buzzerChecked(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.setImage(UIImage(named: "buzzer"), for: .normal)
            sender.tag = 0
        } else {
            sender.setImage(UIImage(named: "mute"), for: .normal)
            sender.tag = 1
        }
    }
    
    @IBAction func ledChecked(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.setImage(UIImage(named: "led"), for: .normal)
            sender.tag = 0
        } else {
            sender.setImage(UIImage(named: "led-off"), for: .normal)
            sender.tag = 1
        }
    }
}
