//
//  CameraViewController.swift
//  Saguna
//
//  Created by Prashant Shrestha on 6/28/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

open class CameraViewController: UIViewController {
    
    // MARK: - Outlets
    public lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        self.view.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        return view
    }()
    
    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer()
        return layer
    }()
    
    lazy var shutterButton: ShutterButton = {
        let view = ShutterButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        return view
    }()
    
    public lazy var flashToggleButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = BaseDimensions.cornerRadius
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 1.0
        view.layer.borderWidth = 2.0
        view.contentEdgeInsets = UIEdgeInsets(top: BaseDimensions.footerViewSpacing, left: BaseDimensions.inset, bottom: BaseDimensions.footerViewSpacing, right: BaseDimensions.inset)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        return view
    }()
    
    private var focusRectangleView: FocusRectangleView!
    
    private lazy var closeBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage.closeImage().scaled(to: CGSize(width: 16, height: 16))?.withRenderingMode(.alwaysTemplate),
                                 style: .plain,
                                 target: self,
                                 action: #selector(closeAction))
        return view
    }()
    
    // MARK: - Properties
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    var captureSessionManager: CaptureSessionManager?
    public var captureSessionDelegate: CaptureSessionDelegate? {
        didSet { captureSessionManager?.delegate = captureSessionDelegate }
    }
    public var cameraPosition: AVCaptureDevice.Position = .back
    
    public var automaticallyAdjustsLeftBarButtonItem = true
    
    public var closeBarButtonIcon: UIImage?
    public var backBarButtonIcon: UIImage?
    private var closeBarAction: (() -> ())?
    
    public var shutterButtonInnerColor: UIColor = UIColor.white {
        didSet {
            if shutterButtonInnerColor != oldValue {
                shutterButton.innerRingColor = shutterButtonInnerColor
            }
        }
    }
    public var shutterButtonOuterColor: UIColor = UIColor.white {
        didSet {
            if shutterButtonOuterColor != oldValue {
                shutterButton.outerRingColor = shutterButtonOuterColor
            }
        }
    }
    public var toggleButtonOnColor: UIColor = UIColor.white {
        didSet {
            if toggleButtonOnColor != oldValue {
                
            }
        }
    }
    public var toggleButtonOffColor: UIColor = UIColor.black {
        didSet {
            if toggleButtonOffColor != oldValue {
                
            }
        }
    }
    public var toggleButtonDisabledColor: UIColor = UIColor.lightGray {
        didSet {
            if toggleButtonOffColor != oldValue {
                
            }
        }
    }
    
    
    // MARK: - Initializers
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        captureSessionManager?.stop()
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.torchMode == .on {
            toggleFlash()
        }
    }
    
    // MARK: - Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let backImage = UIImage()
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        setupViews()
        flashButtonConfig()

        makeUI()
        
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer, position: cameraPosition)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBarConfig()
        if automaticallyAdjustsLeftBarButtonItem {
            adjustLeftBarButtonItem()
        }
        setNeedsStatusBarAppearanceUpdate()
        
        navigationBarConfig()
        
        updateUI()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        CaptureSession.current.isEditing = false
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
        
        updateUI()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoPreviewLayer.frame = contentView.layer.bounds
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        
        self.navigationController?.view.endEditing(true)
        
        captureSessionManager?.stop()
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.torchMode == .on {
            toggleFlash()
        }
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
        
        captureSessionManager?.stop()
        captureSessionManager = nil
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    open func makeUI() {
        updateUI()
    }
    
    open func updateUI() {
        
    }
    
    // MARK: - Camera Configuration Functions
    public func reset() {
        CaptureSession.current.isEditing = false
        captureSessionManager?.start()
    }
    
    public func toggleCameraPosition() {
        cameraPosition = cameraPosition == .back ? .front : .back
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer, position: cameraPosition)
        captureSessionManager?.start()
        flashButtonConfig()
    }
    
    public func hideShutterButton(_ hide: Bool) {
        shutterButton.isHidden = hide
        flashToggleButton.isHidden = hide
    }
    
}

// MARK: - View Configurations
extension CameraViewController {
    // MARK: - Adjusting Navigation Item
    private func navigationBarConfig() {
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.automaticallyAdjustsLeftBarButtonItem = true
    }
    
    private func adjustLeftBarButtonItem() {
        if self.navigationController?.viewControllers.count ?? 0 > 1 { // Pushed
            closeBarButton.image = backBarButtonIcon ?? UIImage.backArrowImage().scaled(to: CGSize(width: 16, height: 16))?.withRenderingMode(.alwaysTemplate)
            if closeBarAction == nil {
                closeBarAction = { [weak self] () in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } else  { // presented
            closeBarButton.image = closeBarButtonIcon ?? UIImage.closeImage().scaled(to: CGSize(width: 16, height: 16))?.withRenderingMode(.alwaysTemplate)
            if closeBarAction == nil {
                closeBarAction = { [weak self] () in
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
        self.navigationItem.leftBarButtonItem = closeBarButton
    }
    
    @objc private func closeAction() {
        closeBarAction?()
    }
    
    private func setupViews() {
        view.backgroundColor = .darkGray
        contentView.backgroundColor = .darkGray
        
        view.contentMode = .scaleAspectFit
        
        contentView.layer.addSublayer(videoPreviewLayer)
        
        contentView.addSubview(shutterButton)
        let shutterButtonConstraints = [
            shutterButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            shutterButton.widthAnchor.constraint(equalToConstant: BaseDimensions.shutterButtonHeight),
            shutterButton.heightAnchor.constraint(equalToConstant: BaseDimensions.shutterButtonHeight),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: shutterButton.bottomAnchor, constant: 8.0)
        ]
        NSLayoutConstraint.activate(shutterButtonConstraints)
        
        contentView.addSubview(flashToggleButton)
        let flashToggleButtonConstraints = [
            flashToggleButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: BaseDimensions.viewSpacing),
            flashToggleButton.rightAnchor.constraint(equalTo: shutterButton.leftAnchor, constant: -BaseDimensions.viewSpacing),
            flashToggleButton.centerYAnchor.constraint(equalTo: shutterButton.centerYAnchor),
        ]
        NSLayoutConstraint.activate(flashToggleButtonConstraints)
    }
}


// MARK: - Focus Rectangle View Configurations
extension CameraViewController {
    @objc private func subjectAreaDidChange() {
        
        do {
            try CaptureSession.current.resetFocusToAuto()
        } catch {
            let error = CameraError.inputDevice
            guard let captureSessionManager = captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
        
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangleView, animated: true)
    }
    
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let touch = touches.first else { return }
        let touchPoint = touch.location(in: contentView)
        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
        
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangleView, animated: false)
        
        focusRectangleView = FocusRectangleView(touchPoint: touchPoint)
        view.addSubview(focusRectangleView)
        
        do {
            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
        } catch {
            let error = CameraError.inputDevice
            guard let captureSessionManager = captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
    }

}

// MARK: - Flash Configurations
extension CameraViewController {
    private func flashButtonConfig() {
        let camera: UIImagePickerController.CameraDevice = cameraPosition == .back ? .rear : .front
        if UIImagePickerController.isFlashAvailable(for: camera) == false {
            let flashOffImage = UIImage.flashUnavailableImage().scaled(to: CGSize(width: 24, height: 24))?.withRenderingMode(.alwaysTemplate)
            flashToggleButton.setImage(flashOffImage, for: .normal)
            flashToggleButton.tintColor = toggleButtonDisabledColor
            flashToggleButton.layer.borderColor = toggleButtonDisabledColor.cgColor
            flashToggleButton.isEnabled = false
        } else {
            let flashImage = UIImage.flashUnavailableImage().scaled(to: CGSize(width: 24, height: 24))?.withRenderingMode(.alwaysTemplate)
            flashToggleButton.setImage(flashImage, for: .normal)
            flashToggleButton.tintColor = toggleButtonOnColor
            flashToggleButton.layer.borderColor = toggleButtonOnColor.cgColor
            flashToggleButton.isEnabled = true
        }
    }
    @objc private func toggleFlash() {
        let state = CaptureSession.current.toggleFlash()

        let flashImage = UIImage.flashImage().scaled(to: CGSize(width: 24, height: 24))?.withRenderingMode(.alwaysTemplate)
        let flashOffImage = UIImage.flashUnavailableImage().scaled(to: CGSize(width: 24, height: 24))?.withRenderingMode(.alwaysTemplate)
        
        switch state {
        case .on:
            flashToggleButton.isEnabled = true
            flashToggleButton.setImage(flashImage, for: .normal)
            flashToggleButton.tintColor = toggleButtonOffColor
            flashToggleButton.layer.borderColor = toggleButtonOnColor.cgColor
            flashToggleButton.backgroundColor = toggleButtonOnColor
            flashToggleButton.layer.shadowColor = toggleButtonOnColor.cgColor
        case .off:
            flashToggleButton.isEnabled = true
            flashToggleButton.setImage(flashOffImage, for: .normal)
            flashToggleButton.tintColor = toggleButtonOnColor
            flashToggleButton.layer.borderColor = toggleButtonOnColor.cgColor
            flashToggleButton.backgroundColor = UIColor.clear
            flashToggleButton.layer.shadowColor = UIColor.clear.cgColor
        case .unknown, .unavailable:
            flashToggleButton.isEnabled = false
            flashToggleButton.setImage(flashOffImage, for: .normal)
            flashToggleButton.tintColor = toggleButtonDisabledColor
            flashToggleButton.layer.borderColor = toggleButtonDisabledColor.cgColor
            flashToggleButton.backgroundColor = UIColor.clear
            flashToggleButton.layer.shadowColor = UIColor.clear.cgColor
        }
    }
}

// MARK: - CaptureImage
extension CameraViewController {
    @objc private func captureImage() {
        captureSessionManager?.capturePhoto()
    }
}
