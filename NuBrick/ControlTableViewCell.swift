//
//  ControlTableViewCell.swift
//  NuBrick
//  各模块参数控制 Cell 类型
//  Created by Eve on 15/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit


protocol ControlCellDelegate {
    func slideUpdate(value: Int, slide: String)
}

class ControlTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var slide: UISlider!
    @IBOutlet weak var valueLabel: UILabel!
    var delegate: ControlCellDelegate?
    
    var slideData: String = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellData(data: SControl) {
        slideData = data.content
        
        self.contentLabel.text = data.content
        self.valueLabel.text = String(data.getting)
        self.slide.maximumValue = Float(data.setting.max)
        self.slide.minimumValue = Float(data.setting.min)
        self.slide.value = Float(data.getting)
    }
    
    @IBAction func valueChanged(_ sender: UISlider) {
        self.valueLabel.text = String(Int(sender.value))
        delegate?.slideUpdate(value: Int(sender.value), slide: slideData)
    }
}
