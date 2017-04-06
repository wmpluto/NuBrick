//
//  KeyViewController.swift
//  NuBrick
//  按键界面
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth


// Key data structure
struct Key {
    var length:          UInt16 = 7
    var sleepPeriod:     UInt16 = 0
    var keyState:        UInt16 = 0
    
    mutating func setKey(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length + 1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.keyState = bytesToWord(head: array[i++], tail: array[i++])
                
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

// Key View Controller
class KeyViewController: SensorViewController {
    
    var key = Key()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        M = KEYM
        // Add a table for parameter
        super.addTable(point: CGPoint(x: 0, y: 65))
        // Send KEYCMD
        self.peripheral.writeValue(KEYCMD!, for: self.writeCharacteristic, type: .withResponse)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func resendCMD() {
        super.resendCMD()
        self.peripheral.writeValue(KEYCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    // Update table
    override func update() {
        super.update()
        var tmp:[SStatus] = []
        tmp.append(SStatus(content: "KeyState", getting: self.key.keyState))
        self.sstatuses = tmp
        
        var cache: [SControl] = []
        cache.append(SControl(content: "SleepPeriod", setting: TIDDATA(value: 0, min: 0, max: 2048), getting: self.key.sleepPeriod))
        self.scontrols = cache
        self.tableView?.reloadData()
    }
 
    // Receive ble data
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        
        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        //guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        let new = self.key.setKey(array: Array(tmpBuffer))
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
