//
//  CaptureSession+Focus.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit

extension CaptureSession {
    
    func setFocusPointToTapPoint(_ tapPoint: CGPoint) throws {
        guard let device = device else { throw CameraError.inputDevice }
        
        try device.lockForConfiguration()
        
        defer { device.unlockForConfiguration() }
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.autoFocus) {
            device.focusPointOfInterest = tapPoint
            device.focusMode = .autoFocus
        }
        
        if device.isExposurePointOfInterestSupported, device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposurePointOfInterest = tapPoint
            device.exposureMode = .continuousAutoExposure
        }
    }
    
    func resetFocusToAuto() throws {
        guard let device = device else { throw CameraError.inputDevice }
        
        try device.lockForConfiguration()
        
        defer { device.unlockForConfiguration() }
        
        if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
    }
    
    func removeFocusRectangleIfNeeded(_ focusRectangle: FocusRectangleView?, animated: Bool) {
        guard let focusRectangle = focusRectangle else { return }
        if animated {
            UIView.animate(withDuration: 0.3, delay: 1.0, animations: {
                focusRectangle.alpha = 0.0
            }, completion: { _ in
                focusRectangle.removeFromSuperview()
            })
        } else {
            focusRectangle.removeFromSuperview()
        }
    }
}
