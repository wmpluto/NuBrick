//
//  GasViewController.swift
//  NuBrick
//
//  Created by mwang on 09/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD
import Charts

struct Gas {
    var length:        UInt16 = 11
    var sleepPeriod:   UInt16 = 0
    var gasAlarmValue: UInt16 = 0
    var gasValue:      UInt16 = 0
    var flag:          UInt8  = 0
    
    mutating func setGas(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > 11 else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.gasAlarmValue = bytesToWord(head: array[i++], tail: array[i++])
                self.gasValue = bytesToWord(head: array[i++], tail: array[i++])
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

class GasViewController: UIViewController {
    
    @IBOutlet weak var lineChartView: LineChartView!
    
    let progressHUD = JGProgressHUD(style: .dark)
    
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    var tmpBuffer:[UInt8] = []
    
    var deviceDescriptor = DeviceDescriptor()
    var deviceData = DeviceData()
    var gas = Gas()
    
    var dataEntries: [ChartDataEntry] = []
    var chartNum: Int = 0
    var set_a: LineChartDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "gas")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        progressHUD?.textLabel.text = "Getting Gas Data..."
        progressHUD?.show(in: self.view, animated: true)
        self.peripheral.delegate = self
        
        self.peripheral.writeValue(GASCMD!, for: self.writeCharacteristic, type: .withResponse)
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
        self.peripheral.writeValue(GASCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    func updateCounter() {
        self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.chartNum), y: Double(self.gas.gasValue)), dataSetIndex: 0)
        self.lineChartView.setVisibleXRange(minXRange: 1, maxXRange: 50)
        self.lineChartView.notifyDataSetChanged()
        self.lineChartView.moveViewToX(Double(self.chartNum))
        self.chartNum = self.chartNum + 1
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


extension GasViewController: CBPeripheralDelegate {
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
            print(tmpBuffer)
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            print(tmpBuffer)
        }
        
        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        new = self.gas.setGas(array: Array(tmpBuffer))
        if new > 0 {
            //print("tmpBuffer before:\(tmpBuffer)")
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print("tmpBuffer after:\(tmpBuffer)")
            if self.lineChartView.data == nil {
                self.set_a = LineChartDataSet(values: [ChartDataEntry(x: Double(0), y: Double(self.gas.gasValue))], label: "gas")
                self.set_a.drawCirclesEnabled = false
                self.set_a.setColor(UIColor.red)
               
                self.lineChartView.data = LineChartData(dataSets: [self.set_a])
                Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
                self.progressHUD?.dismiss()
                
            }
        }
        
    }
}

