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

class DetectBluetoothTableViewController: UITableViewController {

    // Blutetooth
    var centralManager: CBCentralManager!
    var peripherals: [CBPeripheral] = []
    var selectedPeripheral: CBPeripheral!
    
    var refreshCont: UIRefreshControl!
    
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
        self.tableView.reloadData()
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        
        //Stop Scan After 10s
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10.0) {
            self.centralManager.stopScan()
        }
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

        cell.detailTextLabel?.text = ""
        cell.textLabel?.text = peripherals[indexPath.row].name

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
            peripherals.append(peripheral)
        }
        
        self.tableView.reloadData()
    }
}


