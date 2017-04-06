//
//  Torch.swift
//  Torch
//  报警时打开闪光灯
//  Created by mwang on 23/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import AVFoundation


class Torch: NSObject {
    let queue = DispatchQueue(label: "torch.queue")
    
    func turn(status: Bool) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            if (device?.hasTorch)! && (device?.hasFlash)! {
                try device?.lockForConfiguration()
                if status {
                    device?.torchMode = .on
                } else {
                    device?.torchMode = .off
                }
                device?.unlockForConfiguration()
            }
            
        } catch {
            
        }
    }
    
    // Start alarm after delay time
    func startAlarm(delay: Int) {
        queue.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            // the SOS signal: three short, three long, and three more short
            self.short()
            self.short()
            self.short()
            self.long()
            self.long()
            self.long()
            self.short()
            self.short()
            self.short()
        })
    }
    
    // Long interval
    private func long() {
        self.turn(status: true)
        Thread.sleep(forTimeInterval: 2)
        self.turn(status: false)
        Thread.sleep(forTimeInterval: 0.5)
    }
    
    // Short interval
    private func short() {
        self.turn(status: true)
        Thread.sleep(forTimeInterval: 1)
        self.turn(status: false)
        Thread.sleep(forTimeInterval: 0.5)
    }
}
