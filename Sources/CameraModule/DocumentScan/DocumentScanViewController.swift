//
//  DocumentScanViewController.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

public typealias DocumentScanResultCallback = (ImageScanResult) -> Void

open class DocumentScanViewController: CameraViewController {
    
    public enum ScanType {
        case auto
        case manual(_ boxFrame: CGRect)
    }
    
    // MARK: - Outlets
    lazy var autoQuadView: QuadrilateralView = {
        let view = QuadrilateralView()
        view.editable = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var manualQuadView: QuadrilateralView = {
        let view = QuadrilateralView()
        view.editable = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public lazy var scanTypeToggleButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = BaseDimensions.cornerRadius
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 1.0
        view.layer.borderWidth = 2.0
        view.setTitle("AUTO", for: .normal)
        view.setTitleColor(UIColor.white, for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        view.tintColor = UIColor.white
        view.layer.borderColor = UIColor.white.cgColor
        view.isEnabled = true
        view.contentEdgeInsets = UIEdgeInsets(top: BaseDimensions.footerViewSpacing, left: BaseDimensions.inset, bottom: BaseDimensions.footerViewSpacing, right: BaseDimensions.inset)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(toggleScanType), for: .touchUpInside)
        return view
    }()
    
    // MARK: - Properties
    private var scanType: ScanType = .auto
    private var previousScanType: ScanType = .auto
    
    public var quadFillColor: UIColor = UIColor(white: 0.0, alpha: 0.6) {
        didSet {
            if quadFillColor != oldValue {
                autoQuadView.fillColor = quadFillColor
                manualQuadView.fillColor = quadFillColor
            }
        }
    }
    public var quadHighlightColor: UIColor = UIColor(white: 1.0, alpha: 0.5) {
        didSet {
            if quadHighlightColor != oldValue {
                autoQuadView.highlightColor = quadHighlightColor
                manualQuadView.highlightColor = quadHighlightColor
            }
        }
    }
    public var quadStrokeColor: UIColor = UIColor.white {
        didSet {
            if quadStrokeColor != oldValue {
                autoQuadView.strokeColor = quadStrokeColor
                manualQuadView.strokeColor = quadStrokeColor
            }
        }
    }
    
    public var results: DocumentScanResultCallback
    
    
    // MARK: - Initializers
    public init(scanResult: @escaping DocumentScanResultCallback) {
        self.results = scanResult
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.captureSessionDelegate = DocumentScanCaptureSessionDelegateImpl(documentScanViewController: self)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manageQuadView(scanType: scanType)
    }
    
    open override func makeUI() {
        super.makeUI()
        
        contentView.insertSubview(autoQuadView, at: 1)
        let autoQuadViewConstraints = [
            autoQuadView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: autoQuadView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: autoQuadView.rightAnchor),
            autoQuadView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ]
        NSLayoutConstraint.activate(autoQuadViewConstraints)
        
        contentView.insertSubview(manualQuadView, at: 1)
        let manualQuadViewConstraints = [
            manualQuadView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: manualQuadView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: manualQuadView.rightAnchor),
            manualQuadView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ]
        NSLayoutConstraint.activate(manualQuadViewConstraints)
        
        contentView.addSubview(scanTypeToggleButton)
        let scanTypeToggleButtonConstraints = [
            scanTypeToggleButton.leftAnchor.constraint(equalTo: shutterButton.rightAnchor, constant: BaseDimensions.viewSpacing),
            scanTypeToggleButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -BaseDimensions.viewSpacing),
            scanTypeToggleButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
            scanTypeToggleButton.heightAnchor.constraint(equalTo: flashToggleButton.heightAnchor)
        ]
        NSLayoutConstraint.activate(scanTypeToggleButtonConstraints)
    }
    
    @objc private func toggleScanType() {
        let currentScanType = self.scanType
        self.scanType = self.previousScanType
        self.previousScanType = currentScanType
        self.manageQuadView(scanType: self.scanType)
    }
    
    private func manageQuadView(scanType: ScanType) {
        autoQuadView.removeFromSuperview()
        manualQuadView.removeFromSuperview()
        
        switch scanType {
        case .auto:
            contentView.insertSubview(autoQuadView, at: 1)
            let quadViewConstraints = [
                autoQuadView.topAnchor.constraint(equalTo: contentView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: autoQuadView.bottomAnchor),
                contentView.rightAnchor.constraint(equalTo: autoQuadView.rightAnchor),
                autoQuadView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
            ]
            NSLayoutConstraint.activate(quadViewConstraints)
            
            autoQuadView.isMasked = false
            self.reset()
            
            scanTypeToggleButton.isEnabled = true
            scanTypeToggleButton.setTitle("AUTO", for: .normal)
            scanTypeToggleButton.setTitleColor(toggleButtonOffColor, for: .normal)
            scanTypeToggleButton.tintColor = toggleButtonOffColor
            scanTypeToggleButton.layer.borderColor = toggleButtonOnColor.cgColor
            scanTypeToggleButton.backgroundColor = toggleButtonOnColor
            scanTypeToggleButton.layer.shadowColor = toggleButtonOnColor.cgColor
            
        case .manual(let boxFrame):
            contentView.insertSubview(manualQuadView, at: 1)
            let manualQuadViewConstraints = [
                manualQuadView.topAnchor.constraint(equalTo: contentView.topAnchor),
                contentView.bottomAnchor.constraint(equalTo: manualQuadView.bottomAnchor),
                contentView.rightAnchor.constraint(equalTo: manualQuadView.rightAnchor),
                manualQuadView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
            ]
            NSLayoutConstraint.activate(manualQuadViewConstraints)
            
            manualQuadView.isMasked = true
            self.reset()
            
            
            let minX = boxFrame != .zero ? boxFrame.minX : BaseDimensions.viewSpacing
            let minY = boxFrame != .zero ? boxFrame.minY : contentView.bounds.midY * 0.625
            let maxX = boxFrame != .zero ? boxFrame.maxX : contentView.bounds.maxX - BaseDimensions.viewSpacing
            let maxY = boxFrame != .zero ? boxFrame.maxY : contentView.bounds.midY * 1.375
            
            let topLeft = CGPoint(x: minX, y: minY)
            let topRight = CGPoint(x: maxX, y: minY)
            let bottomRight = CGPoint(x: maxX, y: maxY)
            let bottomLeft = CGPoint(x: minX, y: maxY)
            
            manualQuadView.drawQuadrilateral(quad: Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft), animated: true)
            
            manualQuadView.addCornerLines()
            
            manualQuadView.layer.layoutIfNeeded()
            
            scanTypeToggleButton.isEnabled = true
            scanTypeToggleButton.setTitle("MANUAL", for: .normal)
            scanTypeToggleButton.setTitleColor(toggleButtonOnColor, for: .normal)
            scanTypeToggleButton.tintColor = toggleButtonOnColor
            scanTypeToggleButton.layer.borderColor = toggleButtonOnColor.cgColor
            scanTypeToggleButton.backgroundColor = UIColor.clear
            scanTypeToggleButton.layer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    public override func reset() {
        super.reset()
        
        autoQuadView.removeQuadrilateral()
        manualQuadView.removeQuadrilateral()
    }
    
    public func setScanType(_ scanType: ScanType) {
        self.previousScanType = self.scanType
        self.scanType = scanType
        
        if self.autoQuadView.frame != .zero {
            manageQuadView(scanType: self.scanType)
        }
    }
    
    public func currentScanType() -> ScanType {
        return self.scanType
    }
}
