//
//  MusicPlay.swift
//  MusicPlay
//  报警声音播放
//  Created by mwang on 23/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import AudioToolbox


class MusicPlay: NSObject {
    var soundfileObject = SystemSoundID()
    
    init(forResource: String, withExtension: String) {
        super.init()
        let url = Bundle.main.url(forResource: forResource, withExtension: withExtension)
        AudioServicesCreateSystemSoundID(url as! CFURL, &soundfileObject)
    }
    
    private func play() {
        AudioServicesPlaySystemSound(soundfileObject)
    }
    
    private func alert() {
        AudioServicesPlayAlertSound(soundfileObject)
    }
    
    // Start alarm after delay time
    func startAlarm(delay: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            self.play()
            //self.alert()
        })
    }
}
