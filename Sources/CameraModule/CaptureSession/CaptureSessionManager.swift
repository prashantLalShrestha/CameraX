//
//  CaptureSessionManager.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import Foundation
import CoreMotion
import AVFoundation
import UIKit

public final class CaptureSessionManager: NSObject {
    
    private let videoPreviewLayer: AVCaptureVideoPreviewLayer
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    weak var delegate: CaptureSessionDelegate?
    
    // MARK: - Life Cycle
    init?(videoPreviewLayer: AVCaptureVideoPreviewLayer, position: AVCaptureDevice.Position) {
        self.videoPreviewLayer = videoPreviewLayer
        super.init()
        
        guard  let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            let error = CameraError.inputDevice
            delegate?.captureSessionManager(self, didFailWithError: error)
            return nil
        }
        
        self.sessionConfig(for: device)
    }
    
    private func sessionConfig(for device: AVCaptureDevice) {
        
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .photo
        
        photoOutput.isHighResolutionCaptureEnabled = true
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        defer {
            device.unlockForConfiguration()
            captureSession.commitConfiguration()
        }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(deviceInput),
            captureSession.canAddOutput(photoOutput),
            captureSession.canAddOutput(videoOutput),
            captureSession.canAddOutput(metadataOutput) else {
            let error = CameraError.inputDevice
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }
        
        do {
            try device.lockForConfiguration()
        } catch {
            let error = CameraError.inputDevice
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }
        
        device.isSubjectAreaChangeMonitoringEnabled = true
        
        captureSession.addInput(deviceInput)
        captureSession.addOutput(photoOutput)
        captureSession.addOutput(videoOutput)
        captureSession.addOutput(metadataOutput)
        
        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_ouput_queue"))
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue(label: "metadata_output_queue"))
        metadataOutput.metadataObjectTypes = AVMetadataObject.ObjectType.barcodeScannerMetadata
    }
    
    internal func start() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch authorizationStatus {
        case .authorized:
            DispatchQueue.main.async {
                self.captureSession.startRunning()
                self.delegate?.didStartCaptureSession(in: self)
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { _ in
                DispatchQueue.main.async { [weak self] in
                    self?.start()
                }
            })
        default:
            let error = CameraError.authorization
            delegate?.captureSessionManager(self, didFailWithError: error)
        }
    }
    
    internal func stop() {
        captureSession.stopRunning()
        delegate?.didStopCaptureSession(in: self)
    }
    
    internal func capturePhoto() {
        guard let connection = photoOutput.connection(with: .video),
            connection.isEnabled,
            connection.isActive else {
            let error = CameraError.capture
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }
        
        CaptureSession.current.setImageOrientation()
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = true
        if #available(iOS 13.0, *) {
//            photoSettings.isAutoVirtualDeviceFusionEnabled = true
        } else {
            photoSettings.isAutoStillImageStabilizationEnabled = true
        }
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension CaptureSessionManager: AVCaptureMetadataOutputObjectsDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        delegate?.captureSessionManager(self, didOutput: metadataObjects)
    }
}

extension CaptureSessionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageSize = CGSize(width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
        
        delegate?.captureSessionManager(self, didOutput: pixelBuffer, imageSize: imageSize)
    }
}

extension CaptureSessionManager: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }
        
        delegate?.didStartCapturingPicture(from: self)
        
        if let imageData = photo.fileDataRepresentation() {
            guard let image = UIImage(data: imageData) else {
                let error = CameraError.capture
                delegate?.captureSessionManager(self, didFailWithError: error)
                return
            }
            CaptureSession.current.isEditing = true
            delegate?.captureSessionManager(self, didCapturePicture: image)
        } else {
            let error = CameraError.capture
            delegate?.captureSessionManager(self, didFailWithError: error)
            return
        }
    }
}
