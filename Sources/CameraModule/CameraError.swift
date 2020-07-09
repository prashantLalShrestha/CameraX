
//
//  CameraError.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation

public enum CameraError: Error {
    case authorization
    case inputDevice
    case capture
    case ciImageCreation
}

extension CameraError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .authorization:
            return "Faild to get the user's authorization for camera."
        case .inputDevice:
            return "Could not setup input device."
        case .capture:
            return "Could not capture picture."
        case .ciImageCreation:
            return "Internal Error - Could not create CIImage"
        }
    }
}
