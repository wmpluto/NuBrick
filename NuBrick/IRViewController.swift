//
//  IRViewController.swift
//  NuBrick
//
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth

struct IR {
    var length:          UInt16 = 15
    var sleepPeriod:     UInt16 = 0
    var learnedData:     UInt8 = 0
    var useDataType:     UInt8 = 0
    var originalDataNum: UInt8 = 0
    var learnedDataNum:  UInt8 = 0
    var receiveData:     UInt8 = 0
    var sendIRFlag:      UInt8 = 0
    var learnIRFlag:     UInt8 = 0
    
    mutating func setIR(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length + 1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.learnedData = array[i++]
                self.useDataType = array[i++]
                self.originalDataNum = array[i++]
                self.learnedDataNum = array[i++]
                self.receiveData = array[i++]
                self.sendIRFlag = array[i++]
                self.learnIRFlag = array[i++]
                
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

class IRViewController: SensorViewController {
    
    var ir = IR()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        M = IRM
        super.addTable(point: CGPoint(x: 0, y: 65))
        self.peripheral.writeValue(IRCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func resendCMD() {
        super.resendCMD()
        self.peripheral.writeValue(IRCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func update() {
        super.update()
        var tmp:[SStatus] = []
        tmp.append(SStatus(content: "ReceiveData", getting: self.ir.receiveData))
        self.sstatuses = tmp
        
        var cache: [SControl] = []
        cache.append(SControl(content: "SleepPeriod", setting: TIDDATA(value: 0, min: 0, max: 2048), getting: self.ir.sleepPeriod))
        cache.append(SControl(content: "LearnedData", setting: TIDDATA(value: 0, min: 0, max: 6), getting: self.ir.learnedData))
        cache.append(SControl(content: "UsingDataType", setting: TIDDATA(value: 0, min: 0, max: 1), getting: self.ir.useDataType))
        cache.append(SControl(content: "NumberofOriginalData", setting: TIDDATA(value: 0, min: 0, max: 2), getting: self.ir.originalDataNum))
        cache.append(SControl(content: "NumberofLearnedData", setting: TIDDATA(value: 0, min: 0, max: 2048), getting: self.ir.learnedDataNum))
        cache.append(SControl(content: "ReceiveData", setting: TIDDATA(value: 0, min: 0, max: 6), getting: self.ir.receiveData))
        cache.append(SControl(content: "SendIRFlag", setting: TIDDATA(value: 0, min: 0, max: 1), getting: self.ir.sendIRFlag))
        cache.append(SControl(content: "LearnIRFlag", setting: TIDDATA(value: 0, min: 0, max: 1), getting: self.ir.learnIRFlag))
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
        //guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        let new = self.ir.setIR(array: Array(tmpBuffer))
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
