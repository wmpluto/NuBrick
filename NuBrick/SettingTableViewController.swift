//
//  SettingTableViewController.swift
//  NuBrick
//
//  Created by mwang on 19/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var photoAlarm: UISwitch!
    @IBOutlet weak var torchAlarm: UISwitch!
    @IBOutlet weak var musicAlarm: UISwitch!
    
    @IBOutlet weak var batteryAlarm: UISwitch!
    @IBOutlet weak var distanceAlarm: UISwitch!
    @IBOutlet weak var gasAlarm: UISwitch!
    @IBOutlet weak var tempratureAlarm: UISwitch!
    @IBOutlet weak var vibrationAlarm: UISwitch!
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        musicAlarm.setOn(UserDefaults.standard.bool(forKey: EnableMusic), animated: true)
        torchAlarm.setOn(UserDefaults.standard.bool(forKey: EnableTorch), animated: true)
        photoAlarm.setOn(UserDefaults.standard.bool(forKey: EnableCamera), animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.peripheral.delegate = self
        
        self.peripheral.writeValue(DLCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }

        self.progressHUD?.textLabel.text = "Loading ..."
        self.progressHUD?.show(in: self.view, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func musicSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: EnableMusic)
        UserDefaults.standard.set(false, forKey: MusicOn)
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func torchSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: EnableTorch)
        UserDefaults.standard.set(false, forKey: TorchOn)
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func photoSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: EnableCamera)
        UserDefaults.standard.set(false, forKey: CameraOn)
        UserDefaults.standard.synchronize()
    }
    
    
    func resendCMD() {
        print("Something Wrong Resend CMD")
        self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
        self.peripheral.writeValue(DLCMD!, for: self.writeCharacteristic, type: .withResponse)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.6) {
            self.peripheral.writeValue(SSCMD!, for: self.writeCharacteristic, type: .withResponse)
        }
    }
    
    func update() {
        self.analysisStatus()
        //self.tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.peripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
            self.progressHUD?.dismiss()
        })
    }
    
    func analysisStatus() {
        var flag = uintToBool(origin: self.link.buzzerLinkStatus, i: 0) ||
            uintToBool(origin: self.link.ledLinkStatus, i: 0)
        batteryAlarm.setOn(flag, animated: true)
        flag = uintToBool(origin: self.link.buzzerLinkStatus, i: 3) ||
            uintToBool(origin: self.link.ledLinkStatus, i: 3)
        vibrationAlarm.setOn(flag, animated: true)
        flag = uintToBool(origin: self.link.buzzerLinkStatus, i: 4) ||
            uintToBool(origin: self.link.ledLinkStatus, i: 4)
        distanceAlarm.setOn(flag, animated: true)
        flag = uintToBool(origin: self.link.buzzerLinkStatus, i: 5) ||
            uintToBool(origin: self.link.ledLinkStatus, i: 5)
        tempratureAlarm.setOn(flag, animated: true)
        flag = uintToBool(origin: self.link.buzzerLinkStatus, i: 6) ||
            uintToBool(origin: self.link.ledLinkStatus, i: 6)
        gasAlarm.setOn(flag, animated: true)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            break
        case 1:
            if indexPath.row < 5 {
                //default
                self.progressHUD?.textLabel.text = "Apply the Scenario"
                self.progressHUD?.show(in: self.view, animated: true)
                //Send Command
                self.peripheral.writeValue(Default_Scenarios[indexPath.row]!, for: self.writeCharacteristic, type: .withResponse)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    self.progressHUD?.dismiss()
                }
            } else {
                //custom
                self.performSegue(withIdentifier: "toCustomView", sender: self)
            }
            break
        case 2:
            if indexPath.row == 1 {
                print("reconncet ble")
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
            break
        default:
            break
        }
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

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if  let vc = segue.destination as? DeviceLinkViewController {
            vc.peripheral  = self.peripheral
            vc.writeCharacteristic = self.writeCharacteristic
            vc.readCharacteristic = self.readCharacteristic
        }
    }
}



extension SettingTableViewController: CBPeripheralDelegate {
    
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
