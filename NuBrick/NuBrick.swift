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
let rHOOKCMD       = "@HOOK00"
let rVFCMD         = "@d".data(using: .ascii)

// Device Transport Command
let BATTERYCMD     = "@tb".data(using: .ascii)
let BUZZERCMD      = "@tz".data(using: .ascii)
let LEDCMD         = "@tl".data(using: .ascii)
let AHRSCMD        = "@ta".data(using: .ascii)
let SONARCMD       = "@ts".data(using: .ascii)
let TEMPHUMCMD     = "@tt".data(using: .ascii)
let GASCMD         = "@tg".data(using: .ascii)
let KEYCMD         = "@tk".data(using: .ascii)
let IRCMD          = "@ti".data(using: .ascii)

// Device Link Command
let DLCMD          = "@td".data(using: .ascii)

// Device Modify Command
let BATTERYM       = [
    "SleepPeriod":    "@mb11%04d\r",
    "AlarmValue":     "@mb12%04d\r"
]

let BUZZERM        = [
    "SleepPeriod":    "@mz11%04d\r",
    "Volume":         "@mz12%02d\r",
    "Tone":           "@mz13%04d\r",
    "Song":           "@mz14%02d\r",
    "Period":         "@mz15%04d\r",
    "Duty":           "@mz16%02d\r",
    "Latency":        "@mz17%02d\r",
    "StartFlag":      "@mz30%02d\r",
    "StopFlag":       "@mz31%02d\r",
]

let LEDM           = [
    "SleepPeriod":    "@ml11%04d\r",
    "Bright":         "@ml12%02d\r",
    "Color":          "@ml13%04d\r",
    "Blink":          "@ml14%02d\r",
    "Period":         "@ml15%04d\r",
    "Duty":           "@ml16%02d\r",
    "Latency":        "@ml17%02d\r",
    "StartFlag":      "@ml30%02d\r",
    "StopFlag":       "@ml31%02d\r",
]

let AHRSM          =  [
    "SleepPeriod":    "@ma11%04d\r",
    "VibrationLevel": "@ma12%02d\r"
]

let SONARM         = [
    "SleepPeriod":    "@ms11%04d\r",
    "AlarmDistance":  "@ms12%04d\r"
]

let TEMPHUMM       = [
    "SleepPeriod":    "@mt11%04d\r",
    "TempAlarmValue": "@mt12%04d\r",
    "HumiAlarmValue": "@mt13%04d\r",
]

let GASM           = [
    "SleepPeriod":    "@mg11%04d\r",
    "GasLevel":       "@mg12%04d\r"
]

let KEYM           = [
    "SleepPeriod":    "@mk11%04d\r",
]

let IRM            = [
    "SleepPeriod":            "@ml11%04d\r",
    "LearnedData":            "@ml12%02d\r",
    "UsingDataType":          "@ml13%02d\r",
    "NumberofOriginalData":   "@ml14%02d\r",
    "NumberofLearnedData":    "@ml15%02d\r",
    "ReceiveData":            "@ml16%02d\r",
    "SendIRFlag":             "@ml17%02d\r",
    "LearnIRFlag":            "@ml18%02d\r"
]

//6 Default Scenarios
let AHRS_SCENARIO = "@mz400\r@mz431\r@mz440\r@mz450\r@mz460\r@mz470\r@mz481\r@ml400\r@ml431\r@ml440\r@ml450\r@ml460\r\r@ml470\r@ml481\r"
let BATTERY_SCENARIO = "@mz401\r@mz430\r@mz440\r@mz450\r@mz460\r@mz470\r@mz481\r@ml401\r@ml430\r@ml440\r@ml450\r@ml460\r\r@ml470\r@ml481\r"
let GAS_SCENARIO = "@mz400\r@mz430\r@mz440\r@mz450\r@mz461\r@mz470\r@mz481\r@ml400\r@ml430\r@ml440\r@ml450\r@ml461\r\r@ml470\r@ml481\r"
let SONAR_SCENARIO = "@mz400\r@mz430\r@mz441\r@mz450\r@mz460\r@mz470\r@mz481\r@ml400\r@ml430\r@ml441\r@ml450\r@ml460\r\r@ml470\r@ml481\r"
let TEMP_SCENARIO = "@mz400\r@mz430\r@mz440\r@mz450\r@mz460\r@mz470\r@mz481\r@ml400\r@ml430\r@ml440\r@ml450\r@ml460\r@ml470\r@ml481\r"

let Default_Scenarios = [BATTERY_SCENARIO, SONAR_SCENARIO, GAS_SCENARIO, TEMP_SCENARIO, AHRS_SCENARIO].map{$0.data(using: .ascii)}
let Custome_Scenario_Senors = ["battery", "", "", "ahrs", "sonar", "temp", "gas"]

let BATTERY_SCENARIO_CMDS = "@mz40%d\r@ml40%d\r"
let AHRS_SCENARIO_CMDS = "@mz43%d\r@ml43%d\r"
let SONAR_SCENARIO_CMDS = "@mz44%d\r@ml44%d\r"
let TEMP_SCENARIO_CMDS = "@mz45%d\r@ml45%d\r"
let GAS_SCENARIO_CMDS = "@mz46%d\r@ml46%d\r"
let Default_Scenarios_CMDS = [BATTERY_SCENARIO_CMDS, "", "", AHRS_SCENARIO_CMDS, SONAR_SCENARIO_CMDS, TEMP_SCENARIO_CMDS, GAS_SCENARIO_CMDS]
//let BATTERY_SCENARIO = "@mz401\r@ml401\r"

// Communication Start Flag
let StartFlag:UInt8    = 0x55

// TID Set
let TYPEF:            UInt16      = 257
let TYPEI:            UInt16      = 258
let TYPEO:            UInt16      = 259
let types:            Set<UInt16> = [TYPEF, TYPEI, TYPEO]
let addresses:        Set<UInt8>  = [5, 17, 29, 41, 53, 65, 77, 89, 101, 113]
let MINBYTES:         UInt8       = 9
let MINWORD:          UInt8       = 10
let minFlags:         Set<UInt8>  = [MINBYTES, MINWORD]
let MAXBYTES:         UInt8       = 13
let MAXWORD:          UInt8       = 14
let maxFlags:         Set<UInt8>  = [MAXBYTES, MAXWORD]

// Queue
let dataQueue = DispatchQueue(label:"com.nuvoton.dataQueue")

// Sensor
struct Sensor {
    var name:String = ""
    var status:Int = 0
    var alarm:Bool = false
    var connected:Bool = false
    
    init(name:String, status: UInt16,alarm: UInt16,connected: UInt16) {
        self.name = name
        self.status = Int(status)
        self.alarm = alarm > 0 ? true : false
        switch name {

        case "battery":
            self.connected = uintToBool(origin: connected, i: 0)
            break
        case "buzzer" :
            self.connected = uintToBool(origin: connected, i: 1)
            break
        case "led":
            self.connected = uintToBool(origin: connected, i: 2)
            break
        case "ahrs":
            self.connected = uintToBool(origin: connected, i: 3)
            break
        case "sonar":
            self.connected = uintToBool(origin: connected, i: 4)
            break
        case "humidity":
            self.connected = uintToBool(origin: connected, i: 5)
            break
        case "temp":
            self.connected = uintToBool(origin: connected, i: 5)
            break
        case "gas":
            self.connected = uintToBool(origin: connected, i: 6)
            break
        case "ir" :
            self.connected = uintToBool(origin: connected, i: 7)
            break
        case "key" :
            self.connected = uintToBool(origin: connected, i: 8)
            break
        default:
            break
        }
        
    }
}

// Index Report 1st stage
struct IndexReport {
    var start: UInt16 = bytesToWord(head: StartFlag, tail: StartFlag)
    var reportLeng: UInt16 = 0
    var devNum         : UInt16 = 0
    var devConnected   : UInt16 = 0
    var dataLeng  : UInt16 = 0
    
    mutating func setReportLeng(head:UInt8, tail:UInt8) {
        self.reportLeng = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setDevNum(head:UInt8, tail:UInt8) {
        self.devNum = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setDevConnected(head:UInt8, tail:UInt8) {
        self.devConnected = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setDataLeng(head:UInt8, tail:UInt8) {
        self.dataLeng = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setIndexReport(array:[UInt8]) -> Int{
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > (10+1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.start) {
                //Get 1st Stage
                self.start = bytesToWord(head: array[i++], tail: array[i++])
                self.reportLeng = bytesToWord(head: array[i++], tail: array[i++])
                self.devNum = bytesToWord(head: array[i++], tail: array[i++])
                self.devConnected = bytesToWord(head: array[i++], tail: array[i++])
                self.dataLeng = bytesToWord(head: array[i++], tail: array[i++])
                
                if(bytesToWord(head: array[i], tail: array[i+1]) != self.dataLeng) {
                    continue
                }
                
                if i < array.count {
                    print("There is 1st stage: \n\(self)")
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

//Index Data 2nd stage
struct IndexData {
    var start:            UInt16 = 0
    var batteryStatus:    UInt16 = 0
    var batteryAlarm:     UInt16 = 0
    var buzzerStatus:       UInt16 = 0
    var ledStatus:        UInt16 = 0
    var ahrsStatus:   UInt16 = 0
    var ahrsAlarm:    UInt16 = 0
    var sonarStatus:      UInt16 = 0
    var sonarAlarm:       UInt16 = 0
    var tempStatus:     UInt16 = 0
    var humidityStatus:   UInt16 = 0
    var tempAlarm:      UInt16 = 0
    var humidityAlarm:    UInt16 = 0
    var gasStatus:        UInt16 = 0
    var gasAlarm:         UInt16 = 0

    mutating func setIndexData(array:[UInt8]) -> Int{
        print("setIndexData")
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > Int(self.start+1) else {return 0}
            if(bytesToWord(head: array[i], tail: array[i+1]) == self.start) {
                //Get 1st Stage
                self.start = bytesToWord(head: array[i++], tail: array[i++])
                self.batteryStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.batteryAlarm = bytesToWord(head: array[i++], tail: array[i++])
                self.buzzerStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.ledStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.ahrsStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.ahrsAlarm = bytesToWord(head: array[i++], tail: array[i++])
                self.sonarStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.sonarAlarm = bytesToWord(head: array[i++], tail: array[i++])
                self.tempStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.humidityStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.tempAlarm = bytesToWord(head: array[i++], tail: array[i++])
                self.humidityAlarm = bytesToWord(head: array[i++], tail: array[i++])
                self.gasStatus = bytesToWord(head: array[i++], tail: array[i++])
                self.gasAlarm = bytesToWord(head: array[i++], tail: array[i++])

                i = i+Int(self.start)-15*2
                if(bytesToWord(head: array[i], tail: array[i+1]) != self.start) {
                    continue
                }
                
                if i < array.count {
                    print("There is 2nd stage: \n\(self)")
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
        self.devDescLeng = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setRptDescLeng(head:UInt8, tail:UInt8) {
        self.rptDescLeng = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setInRptLeng(head:UInt8, tail:UInt8) {
        self.inRptLeng = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setOutRptLeng(head:UInt8, tail:UInt8) {
        self.outRptLeng = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setGetFeatLeng(head:UInt8, tail:UInt8) {
        self.getFeatLeng = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setSetFeatLeng(head:UInt8, tail:UInt8) {
        self.setFeatLeng = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setCID(head:UInt8, tail:UInt8) {
        self.cid = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setDID(head:UInt8, tail:UInt8) {
        self.did = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setPID(head:UInt8, tail:UInt8) {
        self.pid = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setUID(head:UInt8, tail:UInt8) {
        self.uid = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setUCID(head:UInt8, tail:UInt8) {
        self.ucid = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setReserveOne(head:UInt8, tail:UInt8) {
        self.reserveOne = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setReserveTwo(head:UInt8, tail:UInt8) {
        self.reserveTwo = bytesToWord(head: head, tail: tail)
    }
    /*
    mutating func setDeviceDescriptor(array:[UInt8]) -> Int {
        guard array.count != Int(self.devDescLeng) else { return 0}
        
        self.setDevDescLeng(head: array[0], tail: array[1])
        self.setRptDescLeng(head: array[2], tail: array[3])
        self.setInRptLeng(head: array[4], tail: array[5])
        self.setOutRptLeng(head: array[6], tail: array[7])
        self.setGetFeatLeng(head: array[8], tail: array[9])
        self.setSetFeatLeng(head: array[10], tail: array[12])
        //Others set 0
        return 0
    }
    */
    
    mutating func setDeviceDescriptor(array:[UInt8]) -> Int {
        guard array.count > 2 else {return 0}
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > 4 else {return 0}
            if(array[i] == StartFlag && array[i+1] == StartFlag) {
                //Get 1st Stage
                i += 2
                self.setDevDescLeng(head: array[i++], tail: array[i++])
                guard array.count - i > Int(self.devDescLeng+1) else {return 0}
                self.setRptDescLeng(head: array[i++], tail: array[i++])
                self.setInRptLeng(head: array[i++], tail: array[i++])
                self.setOutRptLeng(head: array[i++], tail: array[i++])
                self.setGetFeatLeng(head: array[i++], tail: array[i++])
                self.setSetFeatLeng(head: array[i++], tail: array[i++])
                self.setCID(head: array[i++], tail: array[i++])
                self.setDID(head: array[i++], tail: array[i++])
                self.setPID(head: array[i++], tail: array[i++])
                self.setUID(head: array[i++], tail: array[i++])
                self.setUCID(head: array[i++], tail: array[i++])
                self.setReserveOne(head: array[i++], tail: array[i++])
                self.setReserveTwo(head: array[i++], tail: array[i++])

                if i < array.count {
                    print("There is 1st stage: \n\(self)")
                    return i
                } else {
                    return 0
                }
            }
            i+=1
        }
        
        return 0
    }
}

// Device Data, the Data in 2nd Stage
struct DeviceData {
    var devDescLeng:     UInt16 = 0
    var parameter:       [DeviceParameter] = []
    
    mutating func setDeviceData(array: [UInt8]) {
        self.devDescLeng = bytesToWord(head: array[0], tail: array[1])
        guard array.count > Int(self.devDescLeng) else { return }
        
        var i = 1
        while i < array.count-3 {
            i += 1
            guard types.contains(bytesToWord(head: array[i], tail: array[i+1])) && addresses.contains(array[i+2]) else { continue }
            var tmpDeviceParameter = DeviceParameter()
            
            tmpDeviceParameter.setDeviceParameter(array: Array(array[i..<array.count]))
            parameter.append(tmpDeviceParameter)
        }
    }
}

struct  DeviceParameter {
    var type:           UInt16 = 0
    var address:        UInt8  = 0
    var length:         UInt8  = 0
    var minFlag:        UInt8  = 0
    var min:            UInt16 = 0
    var maxFlag:        UInt8  = 0
    var max:            UInt16 = 0
    
    mutating func setType(head: UInt8, tail: UInt8) {
        self.type = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setAddress(bytes: UInt8) {
        self.address = bytes
    }
    
    mutating func setLength(bytes: UInt8) {
        self.length = bytes
    }
    
    mutating func setMinFlag(bytes: UInt8) {
        self.minFlag = bytes
    }
    
    mutating func setMin(bytes: UInt8) {
        self.min = UInt16(bytes)
    }
    
    mutating func setMin(head: UInt8, tail: UInt8) {
        self.min = bytesToWord(head: head, tail: tail)
    }
    
    mutating func setExtreme(array: [UInt8]) {
        //only one extreme value
        if self.length == 1 {
            if minFlags.contains(array[0]) {
                self.min = (array[0] == MINBYTES) ? UInt16(array[0]) : bytesToWord(head: array[1], tail: array[2])
            } else if maxFlags.contains(array[0]) {
                self.max = (array[0] == MAXBYTES) ? UInt16(array[0]) : bytesToWord(head: array[1], tail: array[2])
            }
        } else if self.length == 2 {
            var i = 0
            if minFlags.contains(array[0]) {
                self.min = (array[0] == MINBYTES) ? UInt16(array[0]) : bytesToWord(head: array[1], tail: array[2])
                i = (array[0] == MINBYTES) ? 2 : 3
            } else if maxFlags.contains(array[0]) {
                self.max = (array[0] == MAXBYTES) ? UInt16(array[0]) : bytesToWord(head: array[1], tail: array[2])
                i = (array[0] == MAXBYTES) ? 2 : 3
            }
            let tmp = array[i]
            if minFlags.contains(tmp) {
                self.min = (tmp == MINBYTES) ? UInt16(array[++i]) : bytesToWord(head: array[++i], tail: array[++i])
            } else if maxFlags.contains(tmp) {
                self.max = (tmp == MAXBYTES) ? UInt16(array[++i]) : bytesToWord(head: array[++i], tail: array[++i])
            }
        }
    }
    
    mutating func setDeviceParameter(array:[UInt8]) {
        var i = 0
        setType(head: array[i++], tail: array[i++])
        setAddress(bytes: array[i++])
        setLength(bytes: array[i++])
        setExtreme(array: Array(array[i..<(array.count-1)]))
    }
}

struct TIDDATA {
    var value:          Int = 0
    var min:            Int = 0
    var max:            Int = 0
}

// Device Descriptor, the data in 1st stage
struct DeviceLinkDescriptor {
    var devDescLeng:  UInt16 = 8
    var sensorNum:    UInt16 = 8
    var connected:    UInt16 = 0
    var dataLeng:     UInt16 = 6
    
    mutating func setDeviceLinkDescriptor(array:[UInt8]) -> Int {
        guard array.count > 2 else {return 0}
        var i = 0
        
        while i < array.count {
            //Try to Get 1st Stage
            guard array.count - i > 10 else {return 0}
            if(array[i] == StartFlag && array[i+1] == StartFlag) {
                //Get 1st Stage
                i += 2
                self.devDescLeng = bytesToWord(head: array[i++], tail: array[i++])
                self.sensorNum = bytesToWord(head: array[i++], tail: array[i++])
                self.connected = bytesToWord(head: array[i++], tail: array[i++])
                self.dataLeng = bytesToWord(head: array[i++], tail: array[i++])
                
                if self.devDescLeng != 8 || self.dataLeng != 6 {
                    continue
                }
                
                if i < array.count {
                    print("There is 1st stage: \n\(self)")
                    return i
                } else {
                    return 0
                }
            }
            i+=1
        }
        
        return 0
    }
}

struct SControl {
    var content: String = ""
    var setting = TIDDATA()
    var getting: Int = 0
    
    init(content: String, setting: TIDDATA, getting: UInt16) {
        self.content = content
        self.setting = setting
        self.getting = Int(getting)
    }
    
    init(content: String, setting: TIDDATA, getting: UInt8) {
        self.content = content
        self.setting = setting
        self.getting = Int(getting)
    }
}

struct SStatus {
    var content: String = ""
    var getting: Int = 0
    
    init(content: String, getting: UInt16) {
        self.content = content
        self.getting = Int(getting)
    }
    
    init(content: String, getting: UInt8) {
        self.content = content
        self.getting = Int(getting)
    }
}

func bytesToWord(head:UInt8, tail:UInt8) -> UInt16 {
    return UInt16(tail) << 8 | UInt16(head)
}

func uintToBool(origin: UInt16, i: Int) -> Bool {
    if (origin & UInt16(1 << i)) > 0 {
        return true
    }
    return false
}

func invertInt(origin: Int) -> Int {
    let head = origin & 0x00ff
    let tail = origin >> 8
    return Int(head | tail)
}

prefix operator ++
postfix operator ++


// Increment
prefix func ++( x: inout Int) -> Int {
    x += 1
    return x
}

postfix func ++( x: inout Int) -> Int {
    x += 1
    return (x - 1)
}

prefix func ++( x: inout UInt) -> UInt {
    x += 1
    return x
}
