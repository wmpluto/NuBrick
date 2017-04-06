//
//  DeviceLinkViewController.swift
//  NuBrick
//  报警设备绑定页面
//  Created by Eve on 20/1/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth
import JGProgressHUD

// Device link data structure
struct DeviceLink {
    var name: String = ""
    var buzzerLink: Bool = false
    var ledLink: Bool = false
}

// Link status 3rd data structure
struct Link {
    var length:          UInt16 = 6
    var buzzerLinkStatus:     UInt16 = 0
    var ledLinkStatus:        UInt16 = 0
    
    mutating func setLink(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.length + 1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.length) {
                //Get 1st Stage
                self.length = bytesToWord(head: array[i++], tail: array[i++])
                self.buzzerLinkStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.ledLinkStatus = bytesToWord(head: array[i++], tail: array[i++])
                
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

// Device Link View Controller
class DeviceLinkViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let progressHUD = JGProgressHUD(style: .dark)
    
    var peripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    
    var tmpBuffer:[UInt8] = []
    var deviceLinkDescriptor = DeviceLinkDescriptor()
    var link = Link()
    var deviceLinks: [DeviceLink] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.peripheral.delegate = self
        
        tableView?.register(UINib(nibName: "DeviceLinkCell", bundle: nil), forCellReuseIdentifier: "devicelink")
        
        deviceLinks = Custome_Scenario_Senors.map({DeviceLink(name: $0, buzzerLink: false, ledLink: false)})
        // Request device link status
        self.peripheral.writeValue(DLCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.progressHUD?.textLabel.text = "Getting Link Status..."
        self.progressHUD?.show(in: self.view, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //print(deviceLinks)
        // Send the modified device link to NuBrick
        self.peripheral.writeValue(modifyCMD(data: deviceLinks).data(using: .ascii)!, for: self.writeCharacteristic, type: .withResponse)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func resendCMD() {
        print("Something Wrong Resend CMD")
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        self.peripheral.writeValue(DLCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    // Convert the data structure to cmd
    func modifyCMD(data: [DeviceLink]) -> String {
        var tb = ""
        var tl = ""
        for index in 0..<data.count {
            let mb = String(format: "@mz4%d%d\r", index, data[index].buzzerLink ? 1 : 0)
            tb.append(mb)
            let ml = String(format: "@ml4%d%d\r", index, data[index].ledLink ? 1 : 0)
            tl.append(ml)
        }
        //print(tb + tl)
        return tb + tl
    }
    
    // Update the table
    func update() {
        self.analysisStatus()
        self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
            self.progressHUD?.dismiss()
        })
    }
    
    // Analysis the data from NuBrick
    func analysisStatus() {
        for index in 0..<deviceLinks.count {
            deviceLinks[index].buzzerLink = uintToBool(origin: self.link.buzzerLinkStatus, i: index)
            deviceLinks[index].ledLink = uintToBool(origin: self.link.ledLinkStatus, i: index)
        }
    }
}

extension DeviceLinkViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deviceLinks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let device = deviceLinks[indexPath.row]
        if device.name == "" {
            return 0
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "devicelink", for: indexPath) as? DeviceLinkCell
        let device = deviceLinks[indexPath.row]
        
        if device.name == "" {
            cell?.isHidden = true
            return cell!
        }
        
        cell?.delegate = self
        cell?.cellData(data: device)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension DeviceLinkViewController: CBPeripheralDelegate {
   
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("did update value for characteristic")
        guard characteristic.uuid == BTReadUUID else { return }
        let bytesArray:[UInt8] = [UInt8](characteristic.value!)
        print(bytesArray)
        tmpBuffer += bytesArray
        if tmpBuffer.count > 1024 {
            //Something Wrong
            self.resendCMD()
        }
        // Stage 1
        var new = self.deviceLinkDescriptor.setDeviceLinkDescriptor(array: Array(tmpBuffer))
        if new > 0 {
            //print(tmpBuffer)
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            //print(tmpBuffer)
        }
        guard self.deviceLinkDescriptor.connected > 0 else { return }
        new = self.link.setLink(array: Array(tmpBuffer))
        if new > 0 {
            //print(tmpBuffer)
            tmpBuffer = Array(tmpBuffer[new..<tmpBuffer.count])
            self.update()
        }
    }
}

// Link Change Delegate
extension DeviceLinkViewController: LinkChangeDelegate {
    func buzzerLinkChange(status: Bool, device: String) {
        for index in 0..<deviceLinks.count {
            if device == deviceLinks[index].name {
                deviceLinks[index].buzzerLink = status
                break
            }
        }
    }
    
    func ledLinkChange(status: Bool, device: String) {
        for index in 0..<deviceLinks.count {
            if device == deviceLinks[index].name {
                deviceLinks[index].ledLink = status
                break
            }
        }
    }
}
