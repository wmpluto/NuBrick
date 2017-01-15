//
//  ConnectedInputCell.swift
//  NuBrick
//
//  Created by Eve on 15/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit

class ConnectedInputCell: UITableViewCell {

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
        case "ir":
            text += ""
            break
        case "key":
            text += "%"
            break
        default:
            break
        }
    }
}
