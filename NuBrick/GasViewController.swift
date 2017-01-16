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
            guard array.count - i > Int(self.length + 1) else {return 0}
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

class GasViewController: SensorViewController {
    
    @IBOutlet weak var lineChartView: LineChartView!

    var gas = Gas()
    
    var dataEntries: [ChartDataEntry] = []
    var chartNum: Int = 0
    var set_a: LineChartDataSet = LineChartDataSet(values: [ChartDataEntry](), label: "gas")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        M = GASM
        super.addTable(point: CGPoint(x: 0, y: lineChartView.frame.maxY))
        self.peripheral.writeValue(GASCMD!, for: self.writeCharacteristic, type: .withResponse)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func resendCMD() {
        super.resendCMD()
        self.peripheral.writeValue(GASCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func update() {
        super.update()
        self.lineChartView.data?.addEntry(ChartDataEntry(x: Double(self.chartNum), y: Double(self.gas.gasValue)), dataSetIndex: 0)
        self.lineChartView.setVisibleXRange(minXRange: 1, maxXRange: 50)
        self.lineChartView.notifyDataSetChanged()
        self.lineChartView.moveViewToX(Double(self.chartNum))
        self.chartNum = self.chartNum + 1
        
        var tmp:[SStatus] = []
        tmp.append(SStatus(content: "GasSensor", getting: self.gas.gasValue))
        tmp.append(SStatus(content: "OverFlag", getting: self.gas.flag))
        self.sstatuses = tmp
        
        var cache: [SControl] = []
        cache.append(SControl(content: "SleepPeriod", setting: TIDDATA(value: 0, min: 0, max: 1024), getting: self.gas.sleepPeriod))
        cache.append(SControl(content: "GasLevel", setting: TIDDATA(value: 0, min: 0, max: 100), getting: self.gas.gasAlarmValue))
        self.scontrols = cache
        self.tableView?.reloadData()
    }
    
    override func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        super.peripheral(peripheral, didUpdateValueFor: characteristic, error: error)
        //Skip 2nd Stage Try to Get 3rd Stage After 1st Stage
        guard self.deviceDescriptor.rptDescLeng > 0 else { return }
        let new = self.gas.setGas(array: Array(tmpBuffer))
        if new > 0 {
            //print("tmpBuffer before:\(tmpBuffer)")
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print("tmpBuffer after:\(tmpBuffer)")
            if self.lineChartView.data == nil {
                self.set_a = LineChartDataSet(values: [ChartDataEntry(x: Double(0), y: Double(self.gas.gasValue))], label: "gas")
                self.set_a.drawCirclesEnabled = false
                self.set_a.setColor(UIColor.red)
                
                self.lineChartView.data = LineChartData(dataSets: [self.set_a])
                Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(self.update), userInfo: nil, repeats: true)
                self.progressHUD?.dismiss()
            }
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

}

    


