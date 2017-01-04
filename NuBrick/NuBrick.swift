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

// Initial Command
let HOOKCMD        = "@h00".data(using: .ascii)
let SSCMD          = "@ss".data(using: .ascii)
let SPCMD          = "@sp".data(using: .ascii)
let FBCMD          = "@fb".data(using: .ascii)
let VFCMD          = "@vf".data(using: .ascii)
let TXCMD          = "@tx".data(using: .ascii)

// Reponse to Command
let rHOOKCMD       = "@HOOK00".data(using: .ascii)
let rVFCMD         = "@d".data(using: .ascii)

// Device Transport Command
let BATTERYCMD     = "@tb".data(using: .ascii)
let BUZZERCMD      = "@tz".data(using: .ascii)
let LEDCMD         = "@tl".data(using: .ascii)
let ATTITUDECMD    = "@ta".data(using: .ascii)
let SONARCMD       = "@ts".data(using: .ascii)
let TEMPHUMCMD     = "@tt".data(using: .ascii)
let GASCMD         = "@tg".data(using: .ascii)

// Communication Start Flag
let StartFlag:UInt8    = 0x55

// Queue
let dataQueue = DispatchQueue(label:"com.nuvoton.dataQueue")

// Sensor
struct Sensor {
    let name:String
    let status:Int
    let alarm:Bool
    
    init(name:String, status: UInt16,alarm: UInt16) {
        self.name = name
        self.status = Int(status)
        self.alarm = alarm > 0 ? true : false
    }
}

// Index Report 1st stage
struct IndexReport {
    var reportLeng: UInt16 = 0
    var devNum         : UInt16 = 0
    var devConnected   : UInt16 = 0
    var dataLeng  : UInt16 = 0
    
    mutating func setReportLeng(head:UInt8, tail:UInt8) {
        self.reportLeng = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setDevNum(head:UInt8, tail:UInt8) {
        self.devNum = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setDevConnected(head:UInt8, tail:UInt8) {
        self.devConnected = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setDataLeng(head:UInt8, tail:UInt8) {
        self.dataLeng = self.bytesToWord(head: head, tail: tail)
    }
    
    func bytesToWord(head:UInt8, tail:UInt8) -> UInt16 {
        return UInt16(tail) << 8 | UInt16(head)
    }
}

//Index Data 2nd stage
struct IndexData {
    var batteryStatus:    UInt16 = 0
    var batteryAlarm:     UInt16 = 0
    var buzzerStatus:       UInt16 = 0
    var ledStatus:        UInt16 = 0
    var attitudeStatus:   UInt16 = 0
    var attitudeAlarm:    UInt16 = 0
    var sonarStatus:      UInt16 = 0
    var sonarAlarm:       UInt16 = 0
    var temperStatus:     UInt16 = 0
    var humidityStatus:   UInt16 = 0
    var temperAlarm:      UInt16 = 0
    var humidityAlarm:    UInt16 = 0
    var gasStatus:        UInt16 = 0
    var gasAlarm:         UInt16 = 0

    mutating func setBatteryStatus(head:UInt8, tail:UInt8) {
        self.batteryStatus = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setBatteryAlarm(head:UInt8, tail:UInt8) {
        self.batteryAlarm = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setBuzzerStatus(head:UInt8, tail:UInt8) {
        self.buzzerStatus = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setLedStatus(head:UInt8, tail:UInt8) {
        self.ledStatus = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setAttitudeStatus(head:UInt8, tail:UInt8) {
        self.attitudeStatus = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setAttitudeAlarm(head:UInt8, tail:UInt8) {
        self.attitudeAlarm = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setSonarStatus(head:UInt8, tail:UInt8) {
        self.sonarStatus = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setSonarAlarm(head:UInt8, tail:UInt8) {
        self.sonarAlarm = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setTemperStatus(head:UInt8, tail:UInt8) {
        self.temperStatus = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setHumidityStatus(head:UInt8, tail:UInt8) {
        self.humidityStatus = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setTemperAlarm(head:UInt8, tail:UInt8) {
        self.temperAlarm = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setHumidityAlarm(head:UInt8, tail:UInt8) {
        self.humidityAlarm = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setGasStatus(head:UInt8, tail:UInt8) {
        self.gasStatus = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setGasAlarm(head:UInt8, tail:UInt8) {
        self.gasAlarm = self.bytesToWord(head: head, tail: tail)
    }
    
    func bytesToWord(head:UInt8, tail:UInt8) -> UInt16 {
        return UInt16(tail) << 8 | UInt16(head)
    }
}

// Device Descriptor, the data in 1st stage
struct DeviceDescriptor {
    var devDescLeng:    UInt16 = 0
    var rptDescLeng:    UInt16 = 0
    var inRptLeng:      UInt16 = 0
    var outRptLeng:     UInt16 = 0
    var getFeatLeng:    UInt16 = 0
    var setFeatLeng:    UInt16 = 0
    var cid:            UInt16 = 0
    var did:            UInt16 = 0
    var pid:            UInt16 = 0
    var uid:            UInt16 = 0
    var ucid:           UInt16 = 0
    var reserveOne:     UInt16 = 0
    var reserveTwo:     UInt16 = 0
    
    mutating func setDevDescLeng(head:UInt8, tail:UInt8) {
        self.devDescLeng = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setRptDescLeng(head:UInt8, tail:UInt8) {
        self.rptDescLeng = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setInRptLeng(head:UInt8, tail:UInt8) {
        self.inRptLeng = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setOutRptLeng(head:UInt8, tail:UInt8) {
        self.outRptLeng = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setGetFeatLeng(head:UInt8, tail:UInt8) {
        self.getFeatLeng = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setSetFeatLeng(head:UInt8, tail:UInt8) {
        self.setFeatLeng = self.bytesToWord(head: head, tail: tail)
    }
    
    mutating func setDeviceDescriptor(arrary:[UInt8]) {
        guard arrary.count == Int(self.devDescLeng) else { return }
        
        self.setDevDescLeng(head: arrary[0], tail: arrary[1])
        self.setRptDescLeng(head: arrary[2], tail: arrary[3])
        self.setInRptLeng(head: arrary[4], tail: arrary[5])
        self.setOutRptLeng(head: arrary[6], tail: arrary[7])
        self.setGetFeatLeng(head: arrary[8], tail: arrary[9])
        self.setSetFeatLeng(head: arrary[10], tail: arrary[12])
        //Others set 0
    }
    
    func bytesToWord(head:UInt8, tail:UInt8) -> UInt16 {
        return UInt16(tail) << 8 | UInt16(head)
    }
}

// Device Data, the Data in 2nd Stage
struct DeviceData {
    var devDescLeng:     UInt16 = 0
    var parameter:       [DeviceParameter] = []
    
    let types:            Set<UInt16> = [257, 258, 259]
    let addresses:        Set<UInt8>  = [5, 17, 29, 41, 53, 65, 77, 89, 101, 113]
    let minFlags:         Set<UInt8>  = [9, 10]
    let maxFlags:         Set<UInt8>  = [13, 14]
    
    func setDeviceData(arrary: [UInt8]) {
        guard arrary.count == Int(self.devDescLeng) else { return }
        
        var i = -1
        while i < arrary.count {
            i += 1
            guard types.contains(bytesToWord(head: arrary[i], tail: arrary[i+1])) && addresses.contains(arrary[i+2]) else { continue }
            var tmpDeviceParameter = DeviceParameter()
            
            
            
        }
    }
    
    func bytesToWord(head:UInt8, tail:UInt8) -> UInt16 {
        return UInt16(tail) << 8 | UInt16(head)
    }
}

struct  DeviceParameter {
    var type:           UInt16 = 0
    var address:        UInt8  = 0
    var length:         UInt16 = 0
    var minFlag:        UInt8  = 0
    var min:            UInt16 = 0
    var maxFlag:        UInt16 = 0
    var max:            UInt16 = 0
    
    
}

