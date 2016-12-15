//
//  NuBrick.swift
//  NuBrick
//
//  Created by mwang on 13/12/2016.
//  Copyright © 2016 nuvoton. All rights reserved.
//

import Foundation
import CoreBluetooth


let DeviceName   = "NuBrick"

// Device Information
let CompanyCode:   UInt16 = 0
let DeviceCode:    UInt16 = 0
let ProductCode:   UInt16 = 0
let FWCode:        UInt16 = 0
let TypeCode:      UInt16 = 0
let ReservedCode:  UInt16 = 0

// Access UUIDs
let BTDeviceNameUUID = CBUUID(string: "FF00")
let BTWriteUUID      = CBUUID(string: "FF01")
let BTReadUUID       = CBUUID(string: "FF02")


// Device Descriptor, the data in 1st stage
struct DeviceDescriptor {
    var devDescLeng:    UInt16 = 0
    var rptDescLent:    UInt16 = 0
    var inRptLeng:      UInt16 = 0
    var outRptLent:     UInt16 = 0
    var getFeatLeng:    UInt16 = 0
    var setFeatLeng:    UInt16 = 0
    var cid:            UInt16 = 0
    var did:            UInt16 = 0
    var pid:            UInt16 = 0
    var uid:            UInt16 = 0
    var ucid:           UInt16 = 0
    var reserveOne:     UInt16 = 0
    var reserveTwo:     UInt16 = 0
}

// 
struct TIDData {
    var value:          UInt16 = 0
    var minium:         UInt16 = 0
    var maximum:        UInt16 = 0
}

struct TIDFeature {
    var data1:          TIDData
    var data2:          TIDData
    var data3:          TIDData
    var data4:          TIDData
    var data5:          TIDData
    var data6:          TIDData
    var data7:          TIDData
    var data8:          TIDData
    var data9:          TIDData
    var data10:         TIDData
    
}


