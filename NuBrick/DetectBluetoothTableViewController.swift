//
//  DetectBluetoothTableViewController.swift
//  NuBrick
//
//  Created by mwang on 15/12/2016.
//  Copyright © 2016 nuvoton. All rights reserved.
//

import UIKit
import CoreBluetooth
import JGProgressHUD

struct BLEPeripheral {
    let peripheral: CBPeripheral
    let name: String
    let uuid: String
    let rssi: NSNumber?
}


class DetectBluetoothTableViewController: UITableViewController {
    
    // Blutetooth
    var centralManager: CBCentralManager!
    var peripherals: [BLEPeripheral] = []
    var selectedPeripheral: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    
    var refreshCont: UIRefreshControl!
    
    var tmpBuffer:[UInt8] = []
    
    //JGProgressHUD
    let progressHUD = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        title = "Detect Bluetooth"
        
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
        self.setupRefresh()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            print("Start Scan ble")
            self.scanPeripherals()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("View Will Disappear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupRefresh() {
        self.refreshCont = UIRefreshControl()
        self.refreshCont.addTarget(self, action: #selector(DetectBluetoothTableViewController.refreshBLE), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshCont)
    }
    
    @objc private func refreshBLE() {
        print("refresh")
        self.scanPeripherals()
        self.refreshCont.endRefreshing()
    }
    
    private func scanPeripherals() {
        peripherals = centralManager
            .retrieveConnectedPeripherals(withServices: [BTDeviceNameUUID])
            .map { peri -> BLEPeripheral in
                let uuid = peri.identifier.uuidString
                let name = peri.name
                return BLEPeripheral(peripheral: peri, name: name!, uuid: uuid, rssi: nil)
            }
        self.tableView.reloadData()
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        
        //Stop Scan After 10s
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.0) {
            print("Stop Scan ble")
            self.centralManager.stopScan()
        }
    }
    
    private func getRSSILevel(rssi: NSNumber) -> String {
        let movingAverage = rssi.doubleValue
        if movingAverage < -80.0 {
            return "ble-0"
        } else if movingAverage < -70.0 {
            return "ble-1"
        } else if movingAverage < -60.0 {
            return "ble-2"
        } else if movingAverage < -50.0 {
            return "ble-3"
        } else if movingAverage < -40.0 {
            return "ble-4"
        } else {
            return "ble-5"
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("test kvo")
        
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Peripherals Nearby"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLEPeripheral", for: indexPath)
        let blePeripheral:BLEPeripheral = peripherals[indexPath.row]

        let rssi = cell.viewWithTag(1) as! UIImageView
        rssi.image = UIImage(named: getRSSILevel(rssi: blePeripheral.rssi!))
        let name = cell.viewWithTag(2) as! UILabel
        name.text = blePeripheral.name
        let uuid = cell.viewWithTag(3) as! UILabel
        uuid.text = blePeripheral.uuid
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Did SelectRowAt")
        let blePeripheral:BLEPeripheral = peripherals[indexPath.row]
        
        selectedPeripheral = blePeripheral.peripheral
        progressHUD?.textLabel.text = "Connecting to \(blePeripheral.name)"
        progressHUD?.show(in: self.view, animated: true)
        
        centralManager.connect(selectedPeripheral, options: nil)
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
        print("prepare segue")
        progressHUD?.dismiss()
        if segue.identifier == "toNuBrickSensorsTable" {
            
            if  let vc = segue.destination as? AllSensorsTableViewController {
                vc.peripheral  = self.selectedPeripheral
                vc.writeCharacteristic = self.writeCharacteristic
                vc.readCharacteristic = self.readCharacteristic
                centralManager.stopScan()
            }
        }
    }
    

}

extension DetectBluetoothTableViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CentralManagerDidUpdateState")
        switch central.state {
        case CBManagerState.poweredOn:
            print("BluetoothOn")
            
            break
        case CBManagerState.poweredOff:
            print("BluetoothOff")
            
            break
        default:
            print("UnSupport")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("DidConnectPeripheral")
        central.stopScan()

        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        switch central.state {
        case CBManagerState.poweredOn:
            print("BluetoothOn")
            break
        case CBManagerState.poweredOff:
            print("BluetoothOff")
            break
        default:
            print("UnSupport")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("DidFailToConnect")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        for p in peripherals {
            if(p.name == peripheral.name) {
                return
            }
        }
        if ((peripheral.name?.lengthOfBytes(using: String.Encoding.ascii)) != nil) {
            peripherals.append(BLEPeripheral(peripheral: peripheral, name: peripheral.name!, uuid: peripheral.identifier.uuidString, rssi: RSSI))
        }
        
        self.tableView.reloadData()
    }
}

extension DetectBluetoothTableViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for s in peripheral.services! {
            print("scan service", s.uuid.uuidString)
            peripheral.discoverCharacteristics(nil, for: s)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for c in service.characteristics! {
            if c.uuid == BTWriteUUID {
                print(c.uuid.uuidString)
                self.writeCharacteristic = c
                self.selectedPeripheral.writeValue(SPCMD!, for: self.writeCharacteristic, type: .withResponse)
                print("stop it before check device")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    print("hookcmd")
                    self.selectedPeripheral.writeValue(HOOKCMD!, for: self.writeCharacteristic, type: .withResponse)
                }
            }
            
            if c.uuid == BTReadUUID {
                print(c.uuid.uuidString)
                selectedPeripheral.readValue(for: c)
                selectedPeripheral.setNotifyValue(true, for: c)
                self.readCharacteristic = c
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didWriteValueForCharacteristic")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("-----didUpdateNotificationStateForCharacteristic-----")
        if (error != nil) {
            print("error")
        }
        //Notification has started
        if(characteristic.isNotifying){
            peripheral.readValue(for: characteristic);
            print(characteristic.uuid.uuidString);
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("----didUpdateValueForCharacteristic---")
        guard characteristic.uuid == BTReadUUID else { return }

        let bytesArray:[UInt8] = [UInt8](characteristic.value!)
        
        tmpBuffer += bytesArray
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8) {
            //Timeout
            self.progressHUD?.textLabel.text = "TimeOut"
            self.progressHUD?.dismiss()
        }
        
        if(String(bytes: tmpBuffer, encoding: .ascii)?.contains(rHOOKCMD))! {
            print("get hook cmd")
            progressHUD?.textLabel.text = "Connecting to \(DeviceName)"
            self.selectedPeripheral.writeValue(FBCMD!, for: self.writeCharacteristic, type: .withResponse)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.performSegue(withIdentifier: "toNuBrickSensorsTable", sender: self)
            }
        }
    }
}

