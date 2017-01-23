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
import AVFoundation
import Photos

class AllSensorsTableViewController: UITableViewController {
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    var indexReport = IndexReport()
    var indexData = IndexData()
 
    var tmpBuffer:[UInt8] = []
    var sensors:[Sensor] = []
    var outputs:[Sensor] = []
    var inputs:[Sensor] = []

    let progressHUD = JGProgressHUD(style: .dark)
    let torch = Torch()
    let music = MusicPlay(forResource: "BEEP", withExtension: "WAV")

    override func viewDidLoad() {
        super.viewDidLoad()
        print("AllSensorsTableview")
        self.navigationItem.hidesBackButton = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationItem.title = "NuBrick"
        self.addSettingButton(name: "setting")
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        photoAlarm.createAlarm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        progressHUD?.textLabel.text = "Getting All Sensor Data..."
        progressHUD?.show(in: self.view, animated: true)
        
        self.peripheral.delegate = self
        self.peripheral.writeValue(TXCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.peripheral.delegate = nil
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        progressHUD?.dismiss()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resendCMD() {
        print("Something Wrong Resend CMD")
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        self.peripheral.writeValue(TXCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    func addSettingButton(name: String) {
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: name), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        btn1.addTarget(self, action: #selector(self.jumpSetting), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }
    
    func jumpSetting() {
        self.performSegue(withIdentifier: "toSettingView", sender: self)
    }
   
    func alarm() {
        let flag: Bool = sensors.reduce(false, {$0 || $1.alarm})
        
        if flag && !(UserDefaults.standard.bool(forKey: MusicOn) as Bool!) && (UserDefaults.standard.bool(forKey: EnableMusic) as Bool!){
            UserDefaults.standard.set(true, forKey: MusicOn)
            UserDefaults.standard.synchronize()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(NoRespondTime), execute: {
                UserDefaults.standard.set(false, forKey: MusicOn)
                UserDefaults.standard.synchronize()
            })
            music.startAlarm(delay: 1)
        }
        
        
        if flag && !(UserDefaults.standard.bool(forKey: CameraOn) as Bool!) && (UserDefaults.standard.bool(forKey: EnableCamera) as Bool!){
            UserDefaults.standard.set(true, forKey: CameraOn)
            UserDefaults.standard.synchronize()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(NoRespondTime), execute: {
                UserDefaults.standard.set(false, forKey: CameraOn)
                UserDefaults.standard.synchronize()
            })
            photoAlarm.startAlarm(delay: 1)
        }
        
        if flag && !(UserDefaults.standard.bool(forKey: TorchOn) as Bool!) && (UserDefaults.standard.bool(forKey: EnableTorch) as Bool!){
            UserDefaults.standard.set(true, forKey: TorchOn)
            UserDefaults.standard.synchronize()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(NoRespondTime), execute: {
                UserDefaults.standard.set(false, forKey: TorchOn)
                UserDefaults.standard.synchronize()
            })
            torch.startAlarm(delay: 3)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Input"
        } else if section == 1 {
            return "Output"
        }
        return "Sensor"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return self.inputs.count
        } else if section == 1 {
            return self.outputs.count
        }
        return sensors.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let s = inputs[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectedInput", for: indexPath) as? ConnectedInputCell
            cell?.cellData(data: s)
            return cell!
        case 1:
            let s = outputs[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectedOutput", for: indexPath) as? ConnectedOutputCell
            cell?.cellData(data: s)
            return cell!
        case 2:
            let s = sensors[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectedSensor", for: indexPath) as? ConnectedSensorCell
            cell?.cellData(data: s)
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectedSensor", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var s: Sensor
        s = sensors[indexPath.row]
        if indexPath.section == 0 {
            s = inputs[indexPath.row]
        } else if indexPath.section == 1 {
            s = outputs[indexPath.row]
        }
        
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
            case "ir":
                self.performSegue(withIdentifier: "toIRView", sender: self)
                break
            case "key":
                self.performSegue(withIdentifier: "toKeyView", sender: self)
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
            case "sonar":
                self.performSegue(withIdentifier: "toSonarView", sender: self)
                break
            case "temp":
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
            vc.sensor = "AHRS"
        } else if  let vc = segue.destination as? BatteryViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
            vc.sensor = "Battery"
        } else if let vc = segue.destination as? BuzzerViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
            vc.sensor = "Buzzer"
        } else if let vc = segue.destination as? GasViewController {
            vc.peripheral = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
            vc.sensor = "Gas"
        } else if let vc = segue.destination as? IRViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
            vc.sensor = "IR"
        } else if let vc = segue.destination as? KeyViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
            vc.sensor = "Key"
        } else if let vc = segue.destination as? LedViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
            vc.sensor = "Led"
        } else if let vc = segue.destination as? SonarViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
            vc.sensor = "Sonar"
        }  else if let vc = segue.destination as? TemperatureViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
            vc.sensor = "Temp&Humi"
        } else if let vc = segue.destination as? SettingTableViewController {
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
        
        tmpBuffer += bytesArray
        if tmpBuffer.count > 1024 {
            //Something Wrong
            self.resendCMD()
        }
        
        var new = self.indexReport.setIndexReport(array: Array(tmpBuffer))
        if new > 0 {
            print(tmpBuffer)
            self.indexData.start = self.indexReport.dataLeng
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
        }
        
        guard self.indexData.start > 0 else { return }
        new = self.indexData.setIndexData(array: Array(tmpBuffer))
        if new > 0 {
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            self.updateTable()
        }
    }
    
    func updateTable() {
        var tmp:[Sensor] = []
        tmp.append(Sensor(name: "battery", status: self.indexData.batteryStatus, alarm: self.indexData.batteryAlarm, connected: self.indexReport.devConnected))
        tmp.append(Sensor(name: "ahrs", status: self.indexData.ahrsStatus, alarm: self.indexData.ahrsAlarm, connected: self.indexReport.devConnected))
        tmp.append(Sensor(name: "sonar", status: self.indexData.sonarStatus, alarm: self.indexData.sonarAlarm, connected: self.indexReport.devConnected))
        tmp.append(Sensor(name: "temp", status: self.indexData.tempStatus, alarm: self.indexData.tempAlarm, connected: self.indexReport.devConnected))
        tmp.append(Sensor(name: "humidity", status: self.indexData.humidityStatus, alarm: self.indexData.humidityAlarm, connected: self.indexReport.devConnected))
        tmp.append(Sensor(name: "gas", status: self.indexData.gasStatus, alarm: self.indexData.gasAlarm, connected: self.indexReport.devConnected))
        self.sensors = tmp.filter({$0.connected})
        
        tmp = []
        tmp.append(Sensor(name: "buzzer", status: self.indexData.buzzerStatus, alarm: 0, connected: self.indexReport.devConnected))
        tmp.append(Sensor(name: "led", status: self.indexData.ledStatus, alarm: 0, connected: self.indexReport.devConnected))
        self.outputs = tmp.filter({$0.connected})
        
        tmp = []
        tmp.append(Sensor(name: "ir", status: 0, alarm: 0, connected: self.indexReport.devConnected))
        tmp.append(Sensor(name: "key", status: 0, alarm: 0, connected: self.indexReport.devConnected))
        self.inputs = tmp.filter({$0.connected})
        
        DispatchQueue.main.async {
            print("update it")
            self.progressHUD?.dismiss()
            self.alarm()
            self.tableView.reloadData()
        }
    }
}
