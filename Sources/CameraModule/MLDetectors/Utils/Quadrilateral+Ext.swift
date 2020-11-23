//
//  Quadrilateral_Ext.swift
//  Saguna
//
//  Created by Prashant Shrestha on 7/3/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import UIKit
import Vision

extension Quadrilateral {
    
    @available(iOS 11.0, *)
    init(rectangleObservation: VNRectangleObservation) {
        self.topLeft = rectangleObservation.topLeft
        self.topRight = rectangleObservation.topRight
        self.bottomLeft = rectangleObservation.bottomLeft
        self.bottomRight = rectangleObservation.bottomRight
    }
    
    @available(iOS 11.0, *)
    init(qrFeature: CIQRCodeFeature) {
        self.topLeft = qrFeature.topLeft
        self.topRight = qrFeature.topRight
        self.bottomLeft = qrFeature.bottomLeft
        self.bottomRight = qrFeature.bottomRight
    }
}
