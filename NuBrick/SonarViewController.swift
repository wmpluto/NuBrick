//
//  SonarViewController.swift
//  NuBrick
//
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth

struct Sonar {
    var length:          UInt16 = 11
    var sleepPeriod:     UInt16 = 0
    var sonarAlarmValue: UInt16 = 0
    var sonarValue:      UInt16 = 0
    var flag:            UInt8  = 0
    
    mutating func setSonar(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length + 1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.sonarAlarmValue = bytesToWord(head: array[i++], tail: array[i++])
                self.sonarValue = bytesToWord(head: array[i++], tail: array[i++])
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

class SonarViewController: SensorViewController {
   
    @IBOutlet weak var valueLabel: UILabel!
    var sonar = Sonar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheral.writeValue(SONARCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func resendCMD() {
        super.resendCMD()
        self.peripheral.writeValue(SONARCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func update() {
        self.valueLabel.text = String(self.sonar.sonarValue)
        if self.sonar.flag > 0 {
            self.valueLabel.textColor = UIColor.red
        } else {
            self.valueLabel.textColor = UIColor.green
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
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        let new = self.sonar.setSonar(array: Array(tmpBuffer))
        if new > 0 {
            //print("tmpBuffer before:\(tmpBuffer)")
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print("tmpBuffer after:\(tmpBuffer)")
            self.progressHUD?.dismiss()
            Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(self.update), userInfo: nil, repeats: true)
        }
    }

}
