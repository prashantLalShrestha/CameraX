//
//  CaptureSessionDelegate.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

public protocol CaptureSessionDelegate: NSObjectProtocol {
    func didStartCaptureSession(in captureSessionManager: CaptureSessionManager)
    func didStopCaptureSession(in captureSessionManager: CaptureSessionManager)
    func didStartCapturingPicture(from captureSessionManager: CaptureSessionManager)
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didOutput pixelBuffer: CVImageBuffer, imageSize: CGSize)
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didOutput metadataObjects: [AVMetadataObject])
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage)
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error)
}


public extension CaptureSessionDelegate {
    func didStartCaptureSession(in captureSessionManager: CaptureSessionManager) { }
    func didStopCaptureSession(in captureSessionManager: CaptureSessionManager) { }
    func didStartCapturingPicture(from captureSessionManager: CaptureSessionManager) { }
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didOutput pixelBuffer: CVImageBuffer, imageSize: CGSize) { }
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didOutput metadataObjects: [AVMetadataObject]) { }
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage) { }
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) { }
}
