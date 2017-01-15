//
//  StatusTableViewCell.swift
//  NuBrick
//
//  Created by Eve on 15/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {

    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var value: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellData(data: SStatus) {
        self.content.text = data.content
        self.value.text = String(data.getting)
    }
    
}
