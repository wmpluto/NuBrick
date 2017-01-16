//
//  AHRSViewController.swift
//  NuBrick
//
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD

struct AHRS {
    var length:         UInt16 = 10
    var sleepPeriod:    UInt16 = 0
    var vibrationLevel: UInt8 = 0
    var vibrationValue: UInt16 = 0
    var flag:           UInt8  = 0
    
    mutating func setAHRS(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length + 1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.vibrationLevel = array[i++]
                self.vibrationValue = bytesToWord(head: array[i++], tail: array[i++])
                self.flag = array[i++]
                
                if(bytesToWord(head: array[i], tail: array[i+1]) != self.length) {
                    continue
                }
                
                if i < array.count {
                    print("There is 3rd stage: \n\(self)")
                    return i
                } else {
                    return 0
                }
            }
            i += 1
        }
        
        return 0
    }
}


class AHRSViewController: SensorViewController {
    
    @IBOutlet weak var rotationIMG: UIImageView!
    let basic1 = CABasicAnimation(keyPath: "transform.rotation")
    let group = CAAnimationGroup()
    
    var ahrs = AHRS()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        M = AHRSM
        super.addTable(point: CGPoint(x: 0, y: rotationIMG.frame.maxY))
        self.peripheral.writeValue(AHRSCMD!, for: self.writeCharacteristic, type: .withResponse)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func resendCMD() {
        super.resendCMD()
        self.peripheral.writeValue(AHRSCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func update() {
        if self.ahrs.flag == 1 {
            basic1.toValue = 135 / 360 * M_PI * 2
        } else {
            basic1.toValue = 0 * M_PI * 2
        }
        basic1.repeatCount = 1
        basic1.duration = 1.0
        basic1.autoreverses = false
        basic1.fillMode = kCAFillModeForwards
        
        group.duration = 1
        group.repeatCount = 1
        group.animations = [basic1]
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        self.rotationIMG.layer.add(group, forKey: nil)
        
        var tmp:[SStatus] = []
        tmp.append(SStatus(content: "AHRSStatus", getting: self.ahrs.vibrationValue))
        tmp.append(SStatus(content: "OverFlag", getting: self.ahrs.flag))
        self.sstatuses = tmp
        
        var cache: [SControl] = []
        cache.append(SControl(content: "SleepPeriod", setting: TIDDATA(value: 0, min: 0, max: 1024), getting: self.ahrs.sleepPeriod))
        cache.append(SControl(content: "VibrationLevel", setting: TIDDATA(value: 0, min: 1, max: 10), getting: self.ahrs.vibrationLevel))
        self.scontrols = cache
        self.tableView?.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        let new = self.ahrs.setAHRS(array: Array(tmpBuffer))
        if new > 0 {
            //print("tmpBuffer before:\(tmpBuffer)")
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print("tmpBuffer after:\(tmpBuffer)")
            
            if sstatuses.count == 0 {
                self.progressHUD?.dismiss()
            }
            self.update()
        }
    }
}
