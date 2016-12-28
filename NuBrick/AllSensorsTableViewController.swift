//
//  AllSensorsTableViewController.swift
//  NuBrick
//
//  Created by mwang on 16/12/2016.
//  Copyright © 2016 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD


class AllSensorsTableViewController: UITableViewController {
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    var indexReport = IndexReport()
    var indexData = IndexData()
    var buffer:[UInt8] = []
    var tmpBuffer:[UInt8] = []
    
    
    
    let progressHUD = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        print("AllSensorsTableview")
        
        self.peripheral.delegate = self
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds

        self.peripheral.writeValue(TXCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
        }
        self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            // Your code with delay
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AllSensorsTableViewController: CBPeripheralDelegate {
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
        
        let data:Data = characteristic.value!
        let bytesArrary:[UInt8] = [UInt8](data)
        print(bytesArrary)
        
        // process 2nd stage
        if self.indexReport.dataLeng > 0 {
           // save bytes arrary to buffer
            tmpBuffer += bytesArrary
            if tmpBuffer.count > 256 {
                //do something with buffer and clear buffer
                buffer = tmpBuffer
                tmpBuffer = []
                DispatchQueue.main.async {
                    //do something with buffer
                    print("do something with buffer")
                    //find head 
                    var i = 0
                    while i < (self.buffer.count - (Int)(self.indexReport.dataLeng) - 1)  {
                        i += 1
                        let flagBefore = self.indexData.bytesToWord(head: self.buffer[i], tail: self.buffer[i+1])
                        let flagNext = self.indexData.bytesToWord(head: self.buffer[i+(Int)(self.indexReport.dataLeng)], tail: self.buffer[i+(Int)(self.indexReport.dataLeng)+1])
                        if flagBefore == self.indexReport.dataLeng && flagNext == self.indexReport.dataLeng{
                            //get 2nd stage data
                            let da = Array(self.buffer[i+2..<(Int)(self.indexReport.dataLeng)])
                            self.indexData.setBatteryStatus(head: da[0], tail: da[1])
                            self.indexData.setBatteryAlarm(head: da[2], tail: da[3])
                            self.indexData.setBeepStatus(head: da[4], tail: da[5])
                            self.indexData.setLedStatus(head: da[6], tail: da[7])
                            self.indexData.setAttitudeStatus(head: da[8], tail: da[9])
                            self.indexData.setAttitudeAlarm(head: da[10], tail: da[11])
                            self.indexData.setSonarStatus(head: da[12], tail: da[13])
                            self.indexData.setSonarAlarm(head: da[14], tail: da[15])
                            self.indexData.setTemperStatus(head: da[16], tail: da[17])
                            self.indexData.setHumidityStatus(head: da[18], tail: da[19])
                            self.indexData.setTemperAlarm(head: da[20], tail: da[21])
                            self.indexData.setHumidityAlarm(head: da[22], tail: da[23])
                            self.indexData.setGasStatus(head: da[24], tail: da[25])
                            self.indexData.setGasAlarm(head: da[26], tail: da[27])
                            //convert 2nd stage data to 
                            print(self.indexData)
                            i += (Int)(self.indexReport.dataLeng)
                        }
                    }
                    
                }
            }
        }
        
        // get 1st stage
        if bytesArrary[0] == StartFlag  && bytesArrary[1] == StartFlag {
            self.indexReport.setReportLeng(head: bytesArrary[2], tail: bytesArrary[3])
            self.indexReport.setDevNum(head: bytesArrary[4], tail: bytesArrary[5])
            self.indexReport.setDevConnected(head: bytesArrary[6], tail: bytesArrary[7])
            self.indexReport.setDataLeng(head: bytesArrary[8], tail: bytesArrary[9])
        }
    }
}
