//
//  CaptureDevice.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import AVFoundation

protocol CaptureDevice: class {
    var torchMode: AVCaptureDevice.TorchMode { get set }
    var isTorchAvailable: Bool { get }
    
    var focusMode: AVCaptureDevice.FocusMode { get set }
    var focusPointOfInterest: CGPoint { get set }
    var isFocusPointOfInterestSupported: Bool { get }
    
    var exposureMode: AVCaptureDevice.ExposureMode { get set }
    var exposurePointOfInterest: CGPoint { get set }
    var isExposurePointOfInterestSupported: Bool { get }
    
    var isSubjectAreaChangeMonitoringEnabled: Bool { get }
    
    func isFocusModeSupported(_ focusMode: AVCaptureDevice.FocusMode) -> Bool
    func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool
    func unlockForConfiguration()
    func lockForConfiguration() throws
}

extension AVCaptureDevice: CaptureDevice { }
