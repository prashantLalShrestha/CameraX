//
//  RectangleDetectorResult.swift
//  Saguna
//
//  Created by Prashant Shrestha on 7/3/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit

/// Data structure representing the result of the detection of a quadrilateral.
struct RectangleDetectorResult {
    
    /// The detected quadrilateral.
    let rectangle: Quadrilateral
    
    /// The size of the image the quadrilateral was detected on.
    let imageSize: CGSize
    
}
