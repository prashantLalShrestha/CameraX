//
//  FaceScanViewController.swift
//  Saguna
//
//  Created by Prashant Shrestha on 7/3/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

open class FaceScanViewController: CameraViewController {
    
    // MARK: - Outlets
    lazy var quadView: QuadrilateralView = {
        let view = QuadrilateralView()
        view.editable = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    // MARK: - Properties
    
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
    
    public var image: ((UIImage) -> Void)?
    
    
    // MARK: - Initializers
    public override init() {
        super.init()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.toggleCameraPosition()
        self.captureSessionDelegate = FaceScanCaptureSessionDelegateImpl(documentScanViewController: self)
        
        self.hideShutterButton(true)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        manageQuadView()
    }
    
    open override func makeUI() {
        super.makeUI()
        
        contentView.insertSubview(quadView, at: 1)
        let autoQuadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: quadView.rightAnchor),
            quadView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ]
        NSLayoutConstraint.activate(autoQuadViewConstraints)
    }
    
    private func manageQuadView() {
        quadView.removeFromSuperview()

        contentView.insertSubview(quadView, at: 1)
        let quadViewConstraints = [
            quadView.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: quadView.bottomAnchor),
            contentView.rightAnchor.constraint(equalTo: quadView.rightAnchor),
            quadView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
        ]
        NSLayoutConstraint.activate(quadViewConstraints)
        
        quadView.isMasked = false
        quadView.isSkeleton = true
        self.reset()
    }
    
    public override func reset() {
        super.reset()
        
        quadView.removeQuadrilateral()
    }
}
