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
    //var buffer:[UInt8] = []
    var tmpBuffer:[UInt8] = []
    var sensors:[Sensor] = []

    let progressHUD = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        print("AllSensorsTableview")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.peripheral.delegate = nil
        progressHUD?.dismiss()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sensors.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectedSensor", for: indexPath)
        if indexPath.row > sensors.count {
            print("wrong")
            return cell
        }
        let s = sensors[indexPath.row]
        // Configure the cell...
        cell.textLabel?.text = s.name
        cell.detailTextLabel?.text = String(s.status)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let s = sensors[indexPath.row]
        print("Did SelectRowAt\(s.name)")
        
        progressHUD?.textLabel.text = "Showing \(s.name)"
        progressHUD?.show(in: self.view, animated: true)
        
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            // Your code with delay
            switch s.name {
            case "ahrs":
                self.performSegue(withIdentifier: "toAHRSView", sender: self)
                break
            case "battery":
                self.performSegue(withIdentifier: "toBatteryView", sender: self)
                break
            case "buzzer" :
                self.performSegue(withIdentifier: "toBuzzerView", sender: self)
                break
            case "led":
                self.performSegue(withIdentifier: "toLedView", sender: self)
                break
            case "humidity":
                self.performSegue(withIdentifier: "toTemperatureView", sender: self)
                break
            case "gas":
                self.performSegue(withIdentifier: "toGasView", sender: self)
                break
            case "temper":
                self.performSegue(withIdentifier: "toTemperatureView", sender: self)
                break
            default:
                break
            }
        }
    }
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if  let vc = segue.destination as? AHRSViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
        } else if  let vc = segue.destination as? BatteryViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
        } else if let vc = segue.destination as? BuzzerViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
        } else if let vc = segue.destination as? GasViewController {
            vc.peripheral = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
        } else if let vc = segue.destination as? LedViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
        } else if let vc = segue.destination as? TemperatureViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
        }
    }
    

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
        let bytesArray:[UInt8] = [UInt8](characteristic.value!)

        // process 2nd stage
        if self.indexReport.dataLeng > 0 {
           // save bytes array to buffer
            tmpBuffer += bytesArray
            guard tmpBuffer.count > 512 else {return}
            
            dataQueue.sync {
                var buffer = self.tmpBuffer
                self.tmpBuffer = []
                //do something with buffer
                print("do something with buffer")
                //find head 
                var i = 0
                while (i+(Int)(self.indexReport.dataLeng)+1) < buffer.count {
                    let flagBefore = bytesToWord(head: buffer[i], tail: buffer[i+1])
                    let flagNext = bytesToWord(head: buffer[i+(Int)(self.indexReport.dataLeng)], tail: buffer[i+(Int)(self.indexReport.dataLeng)+1])
                    if flagBefore == self.indexReport.dataLeng && flagNext == self.indexReport.dataLeng{
                        //get 2nd stage data
                        self.sensors = []
                        self.processIndexData(da: Array(buffer[i+2..<(i+(Int)(self.indexReport.dataLeng))]))
                        //convert 2nd stage data to 
                        //print(self.indexData)
                        if self.indexReport.dataLeng > 28 {
                            //print("here is custome sensor")
                        }
                        
                        i += (Int)(self.indexReport.dataLeng)-1
                        DispatchQueue.main.async {
                            print("update it")
                            self.tableView.reloadData()
                        }
                    } else {
                        i += 1
                    }
                }
                
            }
        }
        
        
        // get 1st stage
        if bytesArray[0] == StartFlag  && bytesArray[1] == StartFlag {
            self.indexReport.setReportLeng(head: bytesArray[2], tail: bytesArray[3])
            self.indexReport.setDevNum(head: bytesArray[4], tail: bytesArray[5])
            self.indexReport.setDevConnected(head: bytesArray[6], tail: bytesArray[7])
            self.indexReport.setDataLeng(head: bytesArray[8], tail: bytesArray[9])
        }
    }
    
    func processIndexData(da:[UInt8]) {
        guard da.count > 28 else {
            print("please check sensors data")
            return
        }
        
        self.indexData.setBatteryStatus(head: da[0], tail: da[1])
        self.indexData.setBatteryAlarm(head: da[2], tail: da[3])
        self.sensors.append(Sensor(name: "battery", status: self.indexData.batteryStatus, alarm: self.indexData.batteryAlarm))
        
        self.indexData.setBuzzerStatus(head: da[4], tail: da[5])
        self.sensors.append(Sensor(name: "buzzer", status: self.indexData.buzzerStatus, alarm: 0))
        
        self.indexData.setLedStatus(head: da[6], tail: da[7])
        self.sensors.append(Sensor(name: "led", status: self.indexData.ledStatus, alarm: 0))
        
        self.indexData.setAHRSStatus(head: da[8], tail: da[9])
        self.indexData.setAHRSAlarm(head: da[10], tail: da[11])
        self.sensors.append(Sensor(name: "ahrs", status: self.indexData.ahrsStatus, alarm: self.indexData.ahrsAlarm))
        
        self.indexData.setSonarStatus(head: da[12], tail: da[13])
        self.indexData.setSonarAlarm(head: da[14], tail: da[15])
        self.sensors.append(Sensor(name: "sonar", status: self.indexData.sonarStatus, alarm: self.indexData.sonarAlarm))
        
        self.indexData.setTemperStatus(head: da[16], tail: da[17])
        self.indexData.setHumidityStatus(head: da[18], tail: da[19])
        self.indexData.setTemperAlarm(head: da[20], tail: da[21])
        self.indexData.setHumidityAlarm(head: da[22], tail: da[23])
        self.sensors.append(Sensor(name: "temper", status: self.indexData.temperStatus, alarm: self.indexData.temperAlarm))
        self.sensors.append(Sensor(name: "humidity", status: self.indexData.humidityStatus, alarm: self.indexData.humidityStatus))
        
        self.indexData.setGasStatus(head: da[24], tail: da[25])
        self.indexData.setGasAlarm(head: da[26], tail: da[27])
        self.sensors.append(Sensor(name: "gas", status: self.indexData.gasStatus, alarm: self.indexData.gasAlarm))
    }
}
