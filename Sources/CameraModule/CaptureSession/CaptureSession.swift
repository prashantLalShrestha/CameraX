//
//  CaptureSession.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import AVFoundation

final class CaptureSession {
    
    static let current = CaptureSession()
    
    var device: CaptureDevice?
    
    var isEditing: Bool
    
    var editImageOrientation: CGImagePropertyOrientation
    
    private init(editImageOrientation: CGImagePropertyOrientation = .up) {
        self.device = AVCaptureDevice.default(for: .video)
        
        self.isEditing = false
        self.editImageOrientation = editImageOrientation
    }
}
