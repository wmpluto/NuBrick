//
//  PhotographWhenAlarm.swift
//  NuBrick
//  报警时进行拍照
//  Created by mwang on 22/01/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit
import Photos
import AVFoundation


let photoAlarm = PhotographWhenAlarm()

class PhotographWhenAlarm: NSObject, AVCapturePhotoCaptureDelegate {
    
    var captureSesssion: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    
    override init() {
        self.captureSesssion = AVCaptureSession()
        self.stillImageOutput = AVCapturePhotoOutput()
        super.init()
    }
    
    func createAlarm() {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if (captureSesssion?.canAddInput(input))! {
                captureSesssion?.addInput(input)
                if (captureSesssion?.canAddOutput(stillImageOutput))! {
                    captureSesssion?.addOutput(stillImageOutput)
                    captureSesssion?.startRunning()
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    // Start alarm after delay time
    func startAlarm(delay: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
            let settingsForMonitoring = AVCapturePhotoSettings()
            settingsForMonitoring.flashMode = .auto
            settingsForMonitoring.isAutoStillImageStabilizationEnabled = true
            settingsForMonitoring.isHighResolutionPhotoEnabled = false
            self.stillImageOutput?.capturePhoto(with: settingsForMonitoring, delegate: self)
        })
    }
    
    // Store captured photo after alarm
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let photoSampleBuffer = photoSampleBuffer {
            let photoData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
            let image = UIImage(data: photoData!)
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
}
