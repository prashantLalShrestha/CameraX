//
//  PictureEditViewController.swift
//  Saguna
//
//  Created by Prashant Shrestha on 7/3/20.
//  Copyright © 2020 INFICARE PVT. LTD. All rights reserved.
//

import UIKit
import AVFoundation

/// The `PictureEditViewController` offers an interface for the user to edit the detected quadrilateral.
public final class PictureEditViewController: UIViewController {
    
    public struct PictureEditViewClosure {
        let cancelAction: () -> Void
        let failedWithError: (Error) -> Void
        let nextAction: (_ results: ImageScanResult) -> Void
    }
    
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
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        quadView.translatesAutoresizingMaskIntoConstraints = false
        return quadView
    }()
    
    public lazy var nextButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = BaseDimensions.cornerRadius
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 1.0
        view.layer.borderWidth = 2.0
        view.setTitleColor(UIColor.white, for: .normal)
        view.tintColor = UIColor.black
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = UIColor.white
        view.layer.shadowColor = UIColor.white.cgColor
        view.contentEdgeInsets = UIEdgeInsets(top: BaseDimensions.footerViewSpacing, left: BaseDimensions.inset, bottom: BaseDimensions.footerViewSpacing, right: BaseDimensions.inset)
        view.setTitle("NEXT", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        return view
    }()
    
    public lazy var cancelButton: UIButton = {
        let view = UIButton()
        view.layer.cornerRadius = BaseDimensions.cornerRadius
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 2.0
        view.layer.shadowOpacity = 1.0
        view.layer.borderWidth = 2.0
        view.setTitleColor(UIColor.white, for: .normal)
        view.tintColor = UIColor.white
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = UIColor.clear
        view.layer.shadowColor = UIColor.clear.cgColor
        view.contentEdgeInsets = UIEdgeInsets(top: BaseDimensions.footerViewSpacing, left: BaseDimensions.inset, bottom: BaseDimensions.footerViewSpacing, right: BaseDimensions.inset)
        view.setTitle("CANCEL", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return view
    }()
    
    
    private lazy var closeBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(image: UIImage.closeImage().scaled(to: CGSize(width: 16, height: 16))?.withRenderingMode(.alwaysTemplate),
                                 style: .plain,
                                 target: self,
                                 action: #selector(closeAction))
        return view
    }()
    
    // MARK: - Properties
    private let closures: PictureEditViewClosure
    
    public var automaticallyAdjustsLeftBarButtonItem = true
    
    public var closeBarButtonIcon: UIImage?
    public var backBarButtonIcon: UIImage?
    private var closeBarAction: (() -> ())?
    
    /// The image the quadrilateral was detected on.
    private let image: UIImage
    
    /// The detected quadrilateral that can be edited by the user. Uses the image's coordinates.
    private var quad: Quadrilateral
    
    private var zoomGestureController: ZoomGestureController!
    
    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()
    
    
    // MARK: - Initializers
    public init(image: UIImage, rotateImage: Bool = true, closures: PictureEditViewClosure) {
        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.quad = PictureEditViewController.defaultQuad(forImage: image)
        self.closures = closures
        super.init(nibName: nil, bundle: nil)
    }
    
    init(image: UIImage, quad: Quadrilateral?, rotateImage: Bool = true, closures: PictureEditViewClosure) {
        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.quad = quad ?? PictureEditViewController.defaultQuad(forImage: image)
        self.closures = closures
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let backImage = UIImage()
        self.navigationController?.navigationBar.backIndicatorImage = backImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = backImage
        
        setupViews()
        
        makeUI()
        
        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)
        
        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        view.addGestureRecognizer(touchDown)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Work around for an iOS 11.2 bug where UIBarButtonItems don't get back to their normal state after being pressed.
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func makeUI() {
        updateUI()
    }
    
    public func updateUI() {
        
    }
    
    // MARK: - Actions
    @objc func cancelButtonTapped() {
        closures.cancelAction()
    }
    
    
    @objc func nextButtonTapped() {
        guard let quad = quadView.quad,
            let ciImage = CIImage(image: image) else {
                let error = CameraError.ciImageCreation
                closures.failedWithError(error)
                return
        }
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
        let scaledQuad = quad.scale(quadView.bounds.size, image.size)
        self.quad = scaledQuad

        // Cropped Image
        var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: image.size.height)
        cartesianScaledQuad.reorganize()

        let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
           "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
           "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
           "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
           "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
           ])

        let croppedImage = UIImage.from(ciImage: filteredImage)
        // Enhanced Image
        let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
        let enhancedScan = enhancedImage.flatMap { ImageScan(image: $0) }
        
        let result = ImageScanResult(originalScan: ImageScan(image: image),
                                     croppedScan: ImageScan(image: croppedImage),
                                     enhancedScan: enhancedScan)
        
        closures.nextAction(result)
    }
}


// MARK: - View Configurations
extension PictureEditViewController {
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
        
        
        view.addSubview(imageView)
        let imageViewConstraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: imageView.leadingAnchor)
        ]
        
        view.addSubview(quadView)

        quadViewWidthConstraint = quadView.widthAnchor.constraint(equalToConstant: 0.0)
        quadViewHeightConstraint = quadView.heightAnchor.constraint(equalToConstant: 0.0)
        
        let quadViewConstraints = [
            quadView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quadView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quadViewWidthConstraint,
            quadViewHeightConstraint
        ]
        
        NSLayoutConstraint.activate(quadViewConstraints + imageViewConstraints)
        
        
        
        contentView.addSubview(cancelButton)
        let cancelButtonConstraints = [
            cancelButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: BaseDimensions.viewSpacing),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -BaseDimensions.viewSpacing),
        ]
        NSLayoutConstraint.activate(cancelButtonConstraints)
        
        contentView.addSubview(nextButton)
        let nextButtonConstraints = [
            nextButton.leftAnchor.constraint(equalTo: cancelButton.rightAnchor, constant: BaseDimensions.viewSpacing),
            nextButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -BaseDimensions.viewSpacing),
            nextButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -BaseDimensions.viewSpacing),
            nextButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ]
        NSLayoutConstraint.activate(nextButtonConstraints)
    }
}


// MARK: - Quad View Config
extension PictureEditViewController {
    private func displayQuad() {
        let imageSize = image.size
        let imageFrame = CGRect(origin: quadView.frame.origin, size: CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant))
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = quad.applyingTransforms(transforms)
        
        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }
    
    /// The quadView should be lined up on top of the actual image displayed by the imageView.
    /// Since there is no way to know the size of that image before run time, we adjust the constraints to make sure that the quadView is on top of the displayed image.
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }
    
    /// Generates a `Quadrilateral` object that's centered and one third of the size of the passed in image.
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: image.size.width / 3.0, y: image.size.height / 3.0)
        let topRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: image.size.height / 3.0)
        let bottomRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        let bottomLeft = CGPoint(x: image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        
        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        
        return quad
    }
}
