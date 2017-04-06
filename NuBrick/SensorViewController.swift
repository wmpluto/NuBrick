//
//  SensorViewController.swift
//  NuBrick
//  传感器界面父类，所有传感器界面都继承此类以实现表格的添加处理和蓝牙部分数据的处理
//  Created by Eve on 14/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD

class SensorViewController: UIViewController, ControlCellDelegate {
    
    let progressHUD = JGProgressHUD(style: .dark)
    var tableView: UITableView? = nil
    
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    
    var deviceDescriptor = DeviceDescriptor()
    var deviceData = DeviceData()
    var sensor: String = ""
    
    var tmpBuffer:[UInt8] = []
    
    var sstatuses: [SStatus] = []
    var scontrols: [SControl] = []
    
    var modifyCmds: [String: Int] = [:]
    var M : [String: String] = [:]
    
    var deadTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("@\(self.sensor)")
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.peripheral.delegate = self
        // Start streaming
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        deadTime = 0;
        self.progressHUD?.textLabel.text = "Getting \(sensor) Data..."
        self.progressHUD?.show(in: self.view, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause streaming befor view disappear
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Add a table for 'Control Cell' & 'Status Cell'
    func addTable(point: CGPoint) {
        self.tableView = UITableView(frame: CGRect(x: 10, y: point.y, width: self.view.frame.width - 20, height: self.view.frame.height - 15 - point.y))
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.backgroundColor = UIColor.clear
        self.view.addSubview(self.tableView!)
        tableView?.register(UINib(nibName: "ControlTableViewCell", bundle: nil), forCellReuseIdentifier: "ControlCell")
        tableView?.register(UINib(nibName: "StatusTableViewCell", bundle: nil), forCellReuseIdentifier: "StatusCell")
    }
    
    func resendCMD() {
        //print("Something Wrong Resend CMD")
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        //self.peripheral.writeValue(LEDCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    // Send CMDs after the slide value update
    func slideUpdate(value: Int, slide: String) {
        if modifyCmds.count == 0 {
            Timer.scheduledTimer(timeInterval: 3, target:self, selector: #selector(self.sendModifyCMD), userInfo: nil, repeats: false)
        }
        modifyCmds[slide] = value
        deadTime = 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.deadTime = 0
        }
    }
    
    // Convert the CMD arrary to CMD string, then send it out
    func sendModifyCMD() {
        var tmp: String = ""
        let keys = Array(modifyCmds.keys)
        for i in 0..<scontrols.count {
            if keys.contains(scontrols[i].content) {
                tmp.append(String(format: M[scontrols[i].content]!, modifyCmds[scontrols[i].content]!))
            } else {
                tmp.append(String(format: M[scontrols[i].content]!, scontrols[i].getting))
            }
        }
        
        self.peripheral.writeValue(tmp.data(using: .ascii)!, for: self.writeCharacteristic, type: .withResponse)
        modifyCmds = [:]
    }
    
    // Update function
    func update() {
        //print("Update Sensor Status")
    }
}

// CB Peripheral Delegate for ble
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
    
    // Receive ble data
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
        guard self.deadTime == 0 else { print("dead time");tmpBuffer = [];return }
    }
}

extension SensorViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return sstatuses.count
        }
        return scontrols.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Status"
        }
        return "Control"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let s = sstatuses[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath) as? StatusTableViewCell
            cell?.cellData(data: s)
            return cell!
        case 1:
            let s = scontrols[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "ControlCell", for: indexPath) as? ControlTableViewCell
            cell?.delegate = self
            cell?.cellData(data: s)
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectedSensor", for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Nothing to do here
    }
}

