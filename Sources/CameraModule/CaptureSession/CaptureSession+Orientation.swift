//
//  CaptureSession+Orientation.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

extension CaptureSession {
    
    func setImageOrientation() {
        let motion = CMMotionManager()
        
        motion.accelerometerUpdateInterval = 0.01
        
        guard motion.isAccelerometerAvailable else { return }
        
        motion.startAccelerometerUpdates(to: OperationQueue(), withHandler: { data, error in
            guard let data = data, error == nil else { return }
            
            let motionThreshold = 0.35
            
            if data.acceleration.x >= motionThreshold {
                self.editImageOrientation = .left
            } else if data.acceleration.x <= -motionThreshold {
                self.editImageOrientation = .right
            } else {
                self.editImageOrientation = .up
            }
            
            motion.stopAccelerometerUpdates()
            
            switch  UIDevice.current.orientation {
            case .landscapeLeft:
                self.editImageOrientation = .right
            case .landscapeRight:
                self.editImageOrientation = .left
            default:
                break
            }
        })
    }
}
