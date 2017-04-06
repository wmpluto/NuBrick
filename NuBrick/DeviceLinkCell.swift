//
//  DeviceLinkCell.swift
//  NuBrick
//  传感器与输出单元(LED & Buzzer)绑定 Cell 类型
//  Created by Eve on 20/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit


protocol LinkChangeDelegate {
    func buzzerLinkChange(status: Bool, device: String)
    func ledLinkChange(status: Bool, device: String)
}

class DeviceLinkCell: UITableViewCell {

    
    @IBOutlet weak var view: UIImageView!
    @IBOutlet weak var checkBuzzer: UIButton!
    @IBOutlet weak var checkLed: UIButton!
    
    var delegate: LinkChangeDelegate?
    var device: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellData(data: DeviceLink) {
        device = data.name
        
        self.view?.image = UIImage(named: device)
        if data.buzzerLink {
            self.checkBuzzer.setImage(UIImage(named: "buzzer"), for: .normal)
        } else {
            self.checkBuzzer.setImage(UIImage(named: "mute"), for: .normal)
        }
        if data.ledLink {
            self.checkLed.setImage(UIImage(named: "led"), for: .normal)
        } else {
            self.checkLed.setImage(UIImage(named: "led-off"), for: .normal)
        }
    }
    
    @IBAction func buzzerChecked(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.setImage(UIImage(named: "buzzer"), for: .normal)
            sender.tag = 0
            delegate?.buzzerLinkChange(status: true, device: device)
        } else {
            sender.setImage(UIImage(named: "mute"), for: .normal)
            sender.tag = 1
            delegate?.buzzerLinkChange(status: false, device: device)
        }
    }
    
    @IBAction func ledChecked(_ sender: UIButton) {
        if sender.tag == 1 {
            sender.setImage(UIImage(named: "led"), for: .normal)
            sender.tag = 0
            delegate?.ledLinkChange(status: true, device: device)
        } else {
            sender.setImage(UIImage(named: "led-off"), for: .normal)
            sender.tag = 1
            delegate?.ledLinkChange(status: false, device: device)
        }
    }
}
