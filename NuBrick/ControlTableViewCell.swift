//
//  ControlTableViewCell.swift
//  NuBrick
//
//  Created by Eve on 15/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit

protocol ControlCellDelegate {
    func update(sender: UISlider)
}

class ControlTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var slide: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    var delegate: ControlCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellData(data: SControl) {
        self.contentLabel.text = data.content
        self.valueLabel.text = String(data.getting)
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        delegate?.update(sender: sender)
    }
}
