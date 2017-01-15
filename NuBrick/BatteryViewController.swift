//
//  BatteryViewController.swift
//  NuBrick
//
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD

struct Battery {
    var length:        UInt16 = 11
    var sleepPeriod:   UInt16 = 0
    var batteryAlarmValue: UInt16 = 0
    var batteryValue:      UInt16 = 0
    var flag:          UInt8  = 0
    
    mutating func setBattery(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length + 1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.batteryAlarmValue = bytesToWord(head: array[i++], tail: array[i++])
                self.batteryValue = bytesToWord(head: array[i++], tail: array[i++])
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

class BatteryViewController: UIViewController {
    
    let progressHUD = JGProgressHUD(style: .dark)
    
    @IBOutlet weak var rotationIMG: UIImageView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var electricLabel: UILabel!
    let waveImageView = UIImageView(image: UIImage(named: "wave"))
    
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    
    var deviceDescriptor = DeviceDescriptor()
    var deviceData = DeviceData()
    var battery = Battery()
    
    var tmpBuffer:[UInt8] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        progressHUD?.textLabel.text = "Getting Battery Data..."
        progressHUD?.show(in: self.view, animated: true)
        self.peripheral.delegate = self
        
        self.peripheral.writeValue(BATTERYCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resendCMD() {
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        self.peripheral.writeValue(BATTERYCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    func update() {
        let value = Int(self.battery.batteryValue)
        self.electricLabel.text = String(Int(value)) + "%"
        let h = self.bgView.frame.height
        self.electricLabel.text = String(value)
        UIView.animate(withDuration: 4.0, animations: {
            self.waveImageView.frame.origin.y = CGFloat(Double(h) - ((Double(value)/100.0) * Double(h)))
            if  value == 100  {
                self.waveImageView.frame.origin.y = -0;
            }
            self.waveImageView.frame.origin.x = 0;
        })
    }
    
    func waveEffect(value: Int) {
        
        let basic = CABasicAnimation(keyPath: "transform.rotation")
        basic.beginTime = 0
        basic.toValue = M_PI
        basic.duration = 1.0
        basic.autoreverses = false
        basic.fillMode = kCAFillModeForwards
        
        let basic1 = CABasicAnimation(keyPath: "transform.rotation")
        basic1.beginTime = basic.beginTime + basic.duration
        basic1.fromValue = M_PI
        basic1.toValue = M_PI*2
        basic1.repeatCount = 4
        basic1.duration = 1.0
        basic1.autoreverses = false
        basic1.fillMode = kCAFillModeForwards
        
        let group = CAAnimationGroup()
        group.duration = 2
        group.repeatCount = 2
        group.animations = [basic,basic1]
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        self.rotationIMG.layer.add(group, forKey: nil)
        
        let w = self.bgView.frame.width
        let h = self.bgView.frame.height
        self.bgView.layer.cornerRadius = self.bgView.frame.width/2.0
        self.bgView.clipsToBounds = true
        self.bgView.layer.masksToBounds = true
        
        waveImageView.frame = CGRect(x: 0, y: 0, width: 2*w, height: h)
        waveImageView.alpha = 1
        waveImageView.frame.origin.x = 0-w
        waveImageView.frame.origin.y = h
        waveImageView.contentMode = UIViewContentMode.scaleToFill
        
        self.bgView.addSubview(waveImageView)
        
        
        self.electricLabel.text = String(value)
        UIView.animate(withDuration: 4.0, animations: {
            self.waveImageView.frame.origin.y = CGFloat(Double(h) - ((Double(value)/100.0) * Double(h)))
            if  value == 100  {
                self.waveImageView.frame.origin.y = -0;
            }
            self.waveImageView.frame.origin.x = 0;
        })
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


extension BatteryViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("did discover services")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("did discover characteristics for service")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueForCharacteristic")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("did update notification state for characteristic")
        if (error != nil) {
            print("error")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("did update value for characteristic")
        guard characteristic.uuid == BTReadUUID else { return }
        let bytesArray:[UInt8] = [UInt8](characteristic.value!)
        
        tmpBuffer += bytesArray
        if tmpBuffer.count > 1024 {
            //Something Wrong
            self.resendCMD()
        }
        
        var new = self.deviceDescriptor.setDeviceDescriptor(array: Array(tmpBuffer))
        if new > 0 {
            //print(tmpBuffer)
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print(tmpBuffer)
        }
        
        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        new = self.battery.setBattery(array: Array(tmpBuffer))
        if new > 0 {
            //print("tmpBuffer before:\(tmpBuffer)")
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print("tmpBuffer after:\(tmpBuffer)")
            
            if self.electricLabel.text == "00%" {
                self.waveEffect(value: Int(self.battery.batteryValue))
                Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(self.update), userInfo: nil, repeats: true)
                self.progressHUD?.dismiss()
            }
            
        }
        
    }
}

