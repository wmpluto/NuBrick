//
//  ConnectedOutputCell.swift
//  NuBrick
//  首页输出模块对应的 Cell 类型
//  Created by Eve on 15/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit


class ConnectedOutputCell: UITableViewCell {

    @IBOutlet weak var sensorImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellData(data: Sensor) {
        self.sensorImage.image = UIImage(named: data.name)
        var text = String(data.status)
        switch data.name {
        case "buzzer":
            text += ""
            break
        case "led":
            text += "%"
            break
        default:
            break
        }
    }
}
