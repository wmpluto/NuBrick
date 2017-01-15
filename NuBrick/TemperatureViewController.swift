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
import JGProgressHUD

struct TempHumi {
    var length:               UInt16 = 16
    var sleepPeriod:          UInt16 = 0
    var tempAlarmValue:       UInt16 = 0
    var humiAlarmValue:       UInt16 = 0
    var tempValue:            UInt16 = 0
    var humiValue:            UInt16 = 0
    var tempOverFlag:         UInt8 = 0
    var humiOverFlag:         UInt8 = 0
    
    mutating func setTempHumi(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length+1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.sleepPeriod = bytesToWord(head: array[i++], tail: array[i++])
                self.tempAlarmValue = bytesToWord(head: array[i++], tail: array[i++])
                self.humiAlarmValue = bytesToWord(head: array[i++], tail: array[i++])
                self.tempValue = bytesToWord(head: array[i++], tail: array[i++])
                self.humiValue = bytesToWord(head: array[i++], tail: array[i++])
                self.tempOverFlag = array[i++]
                self.humiOverFlag = array[i++]
                
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


class TemperatureViewController: SensorViewController {
    @IBOutlet weak var lineChartView: LineChartView!
    
    var tempHumi = TempHumi()
    
    var dataEntries: [ChartDataEntry] = []
    var chartNum: Int = 0
    var set_a: LineChartDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "temp")
    var set_b: LineChartDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "humidity")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.peripheral.writeValue(TEMPHUMCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func resendCMD() {
        super.resendCMD()
        self.peripheral.writeValue(TEMPHUMCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func update() {
        super.update()
        self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.chartNum), y: Double(self.tempHumi.tempValue)), dataSetIndex: 0)
        self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.chartNum), y: Double(self.tempHumi.humiValue)), dataSetIndex: 1)
        self.lineChartView.setVisibleXRange(minXRange: 1, maxXRange: 50)
        self.lineChartView.notifyDataSetChanged()
        self.lineChartView.moveViewToX(Double(self.chartNum))
        self.chartNum = self.chartNum + 1
    }
    
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        let new = self.tempHumi.setTempHumi(array: Array(tmpBuffer))
        if new > 0 {
            //print("tmpBuffer before:\(tmpBuffer)")
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print("tmpBuffer after:\(tmpBuffer)")
            
            if self.lineChartView.data == nil {
                self.set_a = LineChartDataSet(values: [ChartDataEntry(x: Double(0), y: Double(self.tempHumi.tempValue))], label: "temp")
                self.set_a.drawCirclesEnabled = false
                self.set_a.setColor(UIColor.red)
                self.set_a.axisDependency = .left
                
                self.set_b = LineChartDataSet(values: [ChartDataEntry(x: Double(0), y: Double(self.tempHumi.humiValue))], label: "humidity")
                self.set_b.drawCirclesEnabled = false
                self.set_b.setColor(UIColor.blue)
                self.set_b.axisDependency = .right
                
                self.lineChartView.data = LineChartData(dataSets: [self.set_a, self.set_b])
                Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(self.update), userInfo: nil, repeats: true)
                self.progressHUD?.dismiss()
            }
        }
    }
}
