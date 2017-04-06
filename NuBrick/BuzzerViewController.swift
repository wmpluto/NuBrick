//
//  BuzzerViewController.swift
//  NuBrick
//  蜂鸣器界面
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD


// Buzzer 3rd stage data structure
struct Buzzer {
    var length:        UInt16 = 19
    var sleepPeriod:   UInt16 = 0
    var volume:        UInt8 = 0
    var tone:          UInt16 = 0
    var song:          UInt8 = 0
    var period:        UInt16 = 0
    var duty:          UInt8 = 0
    var latency:       UInt8 = 0
    var executeFlag:   UInt8 = 0
    var startFlag:     UInt8 = 0
    var stopFlag:      UInt8 = 0
    
    mutating func setBuzzer(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length + 1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.volume = array[i++]
                self.tone = bytesToWord(head: array[i++], tail: array[i++])
                self.song = array[i++]
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

// Buzzer View Controller
class BuzzerViewController: SensorViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var buzzer = Buzzer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        M = BUZZERM
        // Add a table for parameter
        super.addTable(point: CGPoint(x: 0, y: imageView.frame.maxY))
        // Send BUZZERCMD
        self.peripheral.writeValue(BUZZERCMD!, for: self.writeCharacteristic, type: .withResponse)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func resendCMD() {
        super.resendCMD()
        self.peripheral.writeValue(BUZZERCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    // Update the table & img
    override func update() {
        super.update()
        if self.buzzer.startFlag == 0 {
            self.imageView.image = UIImage(named: "mute")
            self.label.text = ""
        } else {
            self.imageView.image = UIImage(named: "buzzer")
            self.label.text = String(self.buzzer.volume) + "%"
        }
        
        var tmp:[SStatus] = []
        tmp.append(SStatus(content: "ExecuteFlag", getting: self.buzzer.startFlag))
        self.sstatuses = tmp
        
        var cache: [SControl] = []
        cache.append(SControl(content: "SleepPeriod", setting: TIDDATA(value: 0, min: 0, max: 2048), getting: self.buzzer.sleepPeriod))
        cache.append(SControl(content: "Volume", setting: TIDDATA(value: 0, min: 0, max: 100), getting: self.buzzer.volume))
        cache.append(SControl(content: "Tone", setting: TIDDATA(value: 0, min: 0, max: 5000), getting: self.buzzer.tone))
        cache.append(SControl(content: "Song", setting: TIDDATA(value: 0, min: 0, max: 2), getting: self.buzzer.song))
        cache.append(SControl(content: "Period", setting: TIDDATA(value: 0, min: 0, max: 2048), getting: self.buzzer.period))
        cache.append(SControl(content: "Duty", setting: TIDDATA(value: 0, min: 0, max: 100), getting: self.buzzer.duty))
        cache.append(SControl(content: "Latency", setting: TIDDATA(value: 0, min: 0, max: 60), getting: self.buzzer.latency))
        cache.append(SControl(content: "StartFlag", setting: TIDDATA(value: 0, min: 0, max: 1), getting: self.buzzer.startFlag))
        cache.append(SControl(content: "StopFlag", setting: TIDDATA(value: 0, min: 0, max: 1), getting: self.buzzer.stopFlag))
        self.scontrols = cache
        self.tableView?.reloadData()
    }
    
    // Receive ble data
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)

        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        let new = self.buzzer.setBuzzer(array: Array(tmpBuffer))
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
