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

struct TempHumiValue {
    var length:               UInt16 = 0
    var sleepPeriod:          UInt16 = 0
    var tempAlarmValue:       UInt16 = 0
    var humiAlarmValue:       UInt16 = 0
    var tempValue:            UInt16 = 0
    var humiValue:            UInt16 = 0
    var tempOverFlag:         UInt8 = 0
    var humiOverFlag:         UInt8 = 0

    mutating func setTempHumi(array: [UInt8]) {
        self.length = bytesToWord(head: array[0], tail: array[1])
        self.sleepPeriod = bytesToWord(head: array[2], tail: array[3])
        self.tempAlarmValue = bytesToWord(head: array[4], tail: array[5])
        self.humiAlarmValue = bytesToWord(head: array[6], tail: array[7])
        self.tempValue = bytesToWord(head: array[8], tail: array[9])
        self.humiValue = bytesToWord(head: array[10], tail: array[11])
        self.tempOverFlag = array[12]
        self.humiOverFlag = array[13]
    }
}


class TemperatureViewController: UIViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    var tmpBuffer:[UInt8] = []
    
    var deviceDescriptor = DeviceDescriptor()
    var deviceData = DeviceData()
    var tempHumiValue = TempHumiValue()
    
    var lineBuffer:[Double] = Array(repeating: 0, count: 100)
    var dataEntries: [ChartDataEntry] = []
    
    var chartNum: Int = 0

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
        
        self.lineChartView.setVisibleYRange(minYRange: -50, maxYRange: 50, axis: .left)
        self.lineChartView.setVisibleYRange(minYRange: 0, maxYRange: 100, axis: .right)
        //self.lineChartView.data = LineChartData(dataSet: LineChartDataSet(values: [ChartDataEntry](), label: "Temp"))
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
        let bytesArray:[UInt8] = [UInt8](characteristic.value!)
        
        print(bytesArray)
        //Buffer
        tmpBuffer += bytesArray
        guard tmpBuffer.count > 512 else {return}
        var buffer = self.tmpBuffer
        self.tmpBuffer = []
        //do something with buffer
        print("do something with buffer")
        var i = -1
        while i < buffer.count - 59 {
            i += 1
            //Try to Get 1st Stage
            if(buffer[i] == StartFlag && buffer[i+1] == StartFlag) {
                //Get 1st Stage
                self.deviceDescriptor.setDevDescLeng(head: buffer[i+2], tail: buffer[i+3])
                self.deviceDescriptor.setDeviceDescriptor(array: Array(buffer[(i+2)..<(i+2+Int(self.deviceDescriptor.devDescLeng))]))
                //print("There is 1st stage: \n\(self.deviceDescriptor)")
            }
            //Try to Get 2nd Stage After 1st Stage
            guard self.deviceDescriptor.rptDescLeng > 0 else { continue }
            
            let tmp1 = bytesToWord(head: buffer[i], tail: buffer[i+1])
            let tmp2 = bytesToWord(head: buffer[i+2], tail: buffer[i+3])
            if( tmp1 == self.deviceDescriptor.rptDescLeng && types.contains(tmp2)) {
                deviceData.setDeviceData(array: Array(buffer[i..<buffer.count]))
            }
            //Try to Get 3rd Stage After 2nd Stage
            guard self.deviceData.devDescLeng > 0 else { continue }
            let tmp3 = bytesToWord(head: buffer[i], tail: buffer[i+1])
            let tmp4 = bytesToWord(head: buffer[i+14], tail: buffer[i+15])
            if tmp3 == 16 && tmp4 == 16 {
                tempHumiValue.setTempHumi(array: Array(buffer[i..<i+14]))
                print(tempHumiValue)
                DispatchQueue.main.async {
                    //self.chartNum = self.chartNum % 50 + 1
                    //self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.chartNum), y: Double(self.tempHumiValue.tempValue)), dataSetIndex: 0)
                    //self.lineChartView.data?.addXValue(String(chartNum))
                    self.lineBuffer.append(Double(self.tempHumiValue.tempValue))
                    self.lineBuffer.removeFirst()
                    for i in 0..<self.lineBuffer.count {
                        let dataEntry = ChartDataEntry(x: Double(i), y: Double(0))
                        self.dataEntries.append(dataEntry)
                    }
                    
                    self.lineChartView.data = LineChartData(dataSet: LineChartDataSet(values: self.dataEntries, label: "default"))
                    self.lineChartView.notifyDataSetChanged()
                    //self.lineChartView.moveViewToX(Double(CGFloat(self.chartNum)))
                }
            }
        }
        
        
    }
}