//
//  FocusRectangleView.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit

final class FocusRectangleView: UIView {
    
    convenience init(touchPoint: CGPoint) {
        let originalSize: CGFloat = 200
        let finalSize: CGFloat = 80
        
        let frame = CGRect(x: touchPoint.x - (originalSize * 0.5), y: touchPoint.y - (originalSize * 0.5), width: originalSize, height: originalSize)
        
        self.init(frame: frame)
        
        backgroundColor = .clear
        layer.borderWidth = 2.0
        layer.cornerRadius = 2.0
        layer.borderColor =  UIColor.yellow.cgColor
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseOut, animations: {
            self.frame.origin.x += (originalSize - finalSize) * 0.5
            self.frame.origin.y += (originalSize - finalSize) * 0.5
            
            self.frame.size.width -= (originalSize - finalSize)
            self.frame.size.height -= (originalSize - finalSize)
        }, completion: nil)
    }
}
