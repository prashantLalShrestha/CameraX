//
//  CGRect+Ext.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit

extension CGRect {
    
    func scaleAndCenter(withRatio ratio: CGFloat) -> CGRect {
        let scaleTransform = CGAffineTransform(scaleX: ratio, y: ratio)
        let scaleRect = applying(scaleTransform)
        
        let translateTransform = CGAffineTransform(translationX: origin.x * (1 - ratio) + (width - scaleRect.width) / 2, y: origin.y * (1 - ratio) + (height - scaleRect.height) / 2.0)
        let translatedRect = scaleRect.applying(translateTransform)

        return translatedRect
    }
}
