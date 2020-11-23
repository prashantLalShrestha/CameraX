//
//  AVMetadataObject+Ext.swift
//  CameraX
//
//  Created by Prashant Shrestha on 23/11/2020.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import AVFoundation

extension AVMetadataObject.ObjectType {
  public static let upca: AVMetadataObject.ObjectType = .init(rawValue: "org.gs1.UPC-A")

  /// `AVCaptureMetadataOutput` metadata object types.
  public static var barcodeScannerMetadata = [
    AVMetadataObject.ObjectType.aztec,
    AVMetadataObject.ObjectType.code128,
    AVMetadataObject.ObjectType.code39,
    AVMetadataObject.ObjectType.code39Mod43,
    AVMetadataObject.ObjectType.code93,
    AVMetadataObject.ObjectType.dataMatrix,
    AVMetadataObject.ObjectType.ean13,
    AVMetadataObject.ObjectType.ean8,
    AVMetadataObject.ObjectType.face,
    AVMetadataObject.ObjectType.interleaved2of5,
    AVMetadataObject.ObjectType.itf14,
    AVMetadataObject.ObjectType.pdf417,
    AVMetadataObject.ObjectType.qr,
    AVMetadataObject.ObjectType.upce
  ]
}
