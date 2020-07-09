//
//  Transformable.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import UIKit

protocol Transformable {
    func applying(_ transform: CGAffineTransform) -> Self
}

extension Transformable {
    func applyingTransforms(_ transforms: [CGAffineTransform]) -> Self {
        var transformableObject = self
        
        transforms.forEach { transform in
            transformableObject = transformableObject.applying(transform)
        }
        
        return transformableObject
    }
}
