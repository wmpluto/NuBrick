//
//  TemperatureViewController.swift
//  NuBrick
//
//  Created by mwang on 29/12/2016.
//  Copyright © 2016 nuvoton. All rights reserved.
//

import UIKit
import Charts
import CoreBluetooth

class TemperatureViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    var tmpBuffer:[UInt8] = []
    
    var deviceDescriptor = DeviceDescriptor()
    
    var lineBuffer:[Double] = Array(repeating: 0, count: 100)
    var dataEntries: [ChartDataEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //Set Default Line Chart View
        print("Temperature View")
        
        self.peripheral.delegate = self
        
        self.peripheral.writeValue(TEMPHUMCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
        
        for i in 0..<lineBuffer.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(0))
            dataEntries.append(dataEntry)
        }
        
        lineChartView.data = LineChartData(dataSet: LineChartDataSet(values: dataEntries, label: "default"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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


extension TemperatureViewController: CBPeripheralDelegate {
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
        let bytesArrary:[UInt8] = [UInt8](characteristic.value!)
        
        print(bytesArrary)
        //Buffer
        tmpBuffer += bytesArrary
        guard tmpBuffer.count > 512 else {return}
        var buffer = self.tmpBuffer
        self.tmpBuffer = []
        //do something with buffer
        print("do something with buffer")
        var i = -1
        while i < buffer.count {
            i += 1
            //Try to Get 1st Stage
            if(buffer[i] == StartFlag && buffer[i+1] == StartFlag) {
                //Get 1st Stage
                self.deviceDescriptor.setDevDescLeng(head: buffer[i+2], tail: buffer[i+3])
                self.deviceDescriptor.setDeviceDescriptor(arrary: Array(buffer[(i+2)..<(i+2+Int(self.deviceDescriptor.devDescLeng))]))
                print("There is 1st stage: \n\(self.deviceDescriptor)")
            }
            //Try to Get 2nd Stage After 1st Stage
            guard self.deviceDescriptor.devDescLeng > 0 else { continue }
            
            let tmp = UInt16(buffer[i+1]) << 8 | UInt16(buffer[i])
            if( tmp == self.deviceDescriptor.devDescLeng && buffer[i+2] == StartFlag && buffer[i+3] == StartFlag) {
                
            }
                
            
            
        }
        
    }
}
