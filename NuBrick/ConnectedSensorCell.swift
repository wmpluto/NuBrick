//
//  ConnectedSensorCell.swift
//  NuBrick
//  首页传感器模块对应的 Cell 类型
//  Created by Eve on 15/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit


class ConnectedSensorCell: UITableViewCell {
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var alarmImage: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!

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
        self.alarmImage.image = UIImage(named: (data.alarm) ? "rssi_red" : "rssi_green")
        var text = String(data.status)
        switch data.name {
        case "ahrs":
            text += ""
            break
        case "battery":
            text += "%"
            break
        case "humidity":
            text += "%"
            break
        case "gas":
            text += "%"
            break
        case "sonar":
            text += "m"
            break
        case "temp":
            text += "℃"
            break
        default:
            break
        }
        self.valueLabel.text = text
    }
}
