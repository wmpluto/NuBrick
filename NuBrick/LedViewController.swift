//
//  LedViewController.swift
//  NuBrick
//  LED界面
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD


// LED data structure
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

// Led View Controller
class LedViewController: SensorViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var led = LED()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        M = LEDM
        // Add a table for parameter
        super.addTable(point: CGPoint(x: 0, y: imageView.frame.maxY))
        // Send LEDCMD
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
    
    // Update table
    override func update() {
        super.update()
        if self.led.startFlag == 1 {
            self.label.text = String(self.led.brightness)
            let cv = CGFloat(Float(self.led.color) / 4096.0)
            let cb = CGFloat(Float(self.led.brightness) / 100)
            self.imageView.backgroundColor = UIColor(red: cv, green: cv, blue: cv, alpha: cb)
        }
        
        var tmp:[SStatus] = []
        tmp.append(SStatus(content: "ExecuteFlag", getting: self.led.executeFlag))
        self.sstatuses = tmp
        
        var cache: [SControl] = []
        cache.append(SControl(content: "SleepPeriod", setting: TIDDATA(value: 0, min: 0, max: 1024), getting: self.led.sleepPeriod))
        cache.append(SControl(content: "Bright", setting: TIDDATA(value: 0, min: 0, max: 100), getting: self.led.brightness))
        cache.append(SControl(content: "Color", setting: TIDDATA(value: 0, min: 0, max: 2045), getting: self.led.color))
        cache.append(SControl(content: "Blink", setting: TIDDATA(value: 0, min: 0, max: 2), getting: self.led.blink))
        cache.append(SControl(content: "Period", setting: TIDDATA(value: 0, min: 0, max: 2048), getting: self.led.period))
        cache.append(SControl(content: "Duty", setting: TIDDATA(value: 0, min: 0, max: 100), getting: self.led.duty))
        cache.append(SControl(content: "Latency", setting: TIDDATA(value: 0, min: 0, max: 60), getting: self.led.latency))
        cache.append(SControl(content: "StartFlag", setting: TIDDATA(value: 0, min: 0, max: 1), getting: self.led.startFlag))
        cache.append(SControl(content: "StopFlag", setting: TIDDATA(value: 0, min: 0, max: 1), getting: self.led.stopFlag))
        self.scontrols = cache
        self.tableView?.reloadData()
    }
    
    // Receive ble data
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
}
