//
//  QRScanViewController.swift
//  CameraX
//
//  Created by Prashant Shrestha on 23/11/2020.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

public typealias QRScanValue = String
public typealias QRScanResultCallback = (ImageScanResult, QRScanValue) -> Void

open class QRScanViewController: CameraViewController {
    
    // MARK: - Outlets
    lazy var quadView: QuadrilateralView = {
        let view = QuadrilateralView()
        view.editable = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    var defaultQuad: Quadrilateral?
    public var quadFillColor: UIColor = UIColor(white: 0.0, alpha: 0.6) {
        didSet {
            if quadFillColor != oldValue {
                quadView.fillColor = quadFillColor
            }
        }
    }
    public var quadHighlightColor: UIColor = UIColor(white: 1.0, alpha: 0.5) {
        didSet {
            if quadHighlightColor != oldValue {
                quadView.highlightColor = quadHighlightColor
            }
        }
    }
    public var quadStrokeColor: UIColor = UIColor.white {
        didSet {
            if quadStrokeColor != oldValue {
                quadView.strokeColor = quadStrokeColor
            }
        }
    }
    
    public var results: QRScanResultCallback
    
    
    // MARK: - Initializers
    public init(scanResult: QRScanResultCallback? = nil) {
        self.results = scanResult ?? { _,_ in }
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.captureSessionDelegate = QRScanCaptureSessionDelegateImpl(qrScanViewController: self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manageQuadView()
    }
    
    open override func makeUI() {
        super.makeUI()
        
        contentView.insertSubview(quadView, belowSubview: flashToggleButton)
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: quadView.rightAnchor),
            quadView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ]
        NSLayoutConstraint.activate(quadViewConstraints)
        
        hideShutterButton(true)
    }
    
    
    private func manageQuadView() {
        quadView.removeFromSuperview()

        contentView.insertSubview(quadView, belowSubview: flashToggleButton)
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: quadView.rightAnchor),
            quadView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ]
        NSLayoutConstraint.activate(quadViewConstraints)

        quadView.isMasked = false
        self.reset()


        let minY = contentView.bounds.midY * 0.625
        let maxY = contentView.bounds.midY * 1.375
        let minX = contentView.bounds.midX - (maxY - minY) / 2
        let maxX = contentView.bounds.midX + (maxY - minY) / 2

        let topLeft = CGPoint(x: minX, y: minY)
        let topRight = CGPoint(x: maxX, y: minY)
        let bottomRight = CGPoint(x: maxX, y: maxY)
        let bottomLeft = CGPoint(x: minX, y: maxY)

        defaultQuad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        quadView.drawQuadrilateral(quad: defaultQuad!, animated: true)

        quadView.layer.layoutIfNeeded()
    }
    
    public override func reset() {
        super.reset()
        
        quadView.removeQuadrilateral()
    }
}
