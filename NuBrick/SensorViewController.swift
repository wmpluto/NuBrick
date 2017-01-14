//
//  SensorViewController.swift
//  NuBrick
//
//  Created by Eve on 14/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD

class SensorViewController: UIViewController {
    
    let progressHUD = JGProgressHUD(style: .dark)
    
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    
    var deviceDescriptor = DeviceDescriptor()
    var deviceData = DeviceData()
    var sensor: String = ""
    
    var tmpBuffer:[UInt8] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("@\(self.sensor)")
        self.progressHUD?.textLabel.text = "Getting \(sensor) Data..."
        self.progressHUD?.show(in: self.view, animated: true)
        self.peripheral.delegate = self
        
        //self.peripheral.writeValue(LEDCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resendCMD() {
        print("Something Wrong Resend CMD")
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        //self.peripheral.writeValue(LEDCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    func update() {
        print("Update Sensor Status")
        
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

extension SensorViewController: CBPeripheralDelegate {
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
        // Stage 1
        let new = self.deviceDescriptor.setDeviceDescriptor(array: Array(tmpBuffer))
        if new > 0 {
            //print(tmpBuffer)
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print(tmpBuffer)
        }
    }
}

