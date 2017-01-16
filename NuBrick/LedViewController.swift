//
//  LedViewController.swift
//  NuBrick
//
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD


struct LED {
    var length:        UInt16 = 19
    var sleepPeriod:   UInt16 = 0
    var brightness:    UInt8 = 0
    var color:         UInt16 = 0
    var blink:         UInt8 = 0
    var period:        UInt16 = 0
    var duty:          UInt8 = 0
    var latency:       UInt8 = 0
    var executeFlag:   UInt8 = 0
    var startFlag:     UInt8 = 0
    var stopFlag:      UInt8 = 0
    
    mutating func setLed(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length + 1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.brightness = array[i++]
                self.color = bytesToWord(head: array[i++], tail: array[i++])
                self.blink = array[i++]
                self.period = bytesToWord(head: array[i++], tail: array[i++])
                self.duty = array[i++]
                self.latency = array[i++]
                self.executeFlag = array[i++]
                self.startFlag = array[i++]
                self.stopFlag = array[i++]
                
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

class LedViewController: SensorViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var led = LED()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.peripheral.writeValue(LEDCMD!, for: self.writeCharacteristic, type: .withResponse)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func resendCMD() {
        super.resendCMD()
        self.peripheral.writeValue(LEDCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func update() {
        super.update()
        if self.led.startFlag == 1 {
            self.label.text = String(self.led.brightness)
            let cv = CGFloat(Float(self.led.color) / 4096.0)
            let cb = CGFloat(Float(self.led.brightness) / 100)
            self.imageView.backgroundColor = UIColor(red: cv, green: cv, blue: cv, alpha: cb)
        }
    }
    
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        let new = self.led.setLed(array: Array(tmpBuffer))
        if new > 0 {
            //print("tmpBuffer before:\(tmpBuffer)")
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print("tmpBuffer after:\(tmpBuffer)")
            
            if self.label.text == "00%" {
                self.progressHUD?.dismiss()
            }
            self.update()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
