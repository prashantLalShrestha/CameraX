//
//  CGImagePropertyOrientation.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/30/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import UIKit

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            assertionFailure("Unknow orientation, falling to default")
            self = .right
        }
    }
}
