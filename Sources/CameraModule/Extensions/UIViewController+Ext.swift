//
//  UIViewController+Ext.swift
//  CameraX
//
//  Created by Prashant Shrestha on 27/11/2020.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit

extension UIViewController {
    func openSettingsApp() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
}
