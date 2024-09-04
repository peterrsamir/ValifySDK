//
//  CameraViewController.swift
//  ValifySDK
//
//  Created by Peter Samir on 29/08/2024.
//

import UIKit
import AVFoundation

class CameraViewController: BaseViewController {
    // MARK: - Properties
    private let viewModel: CameraViewModel
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - UI Elements
    private lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
           button.backgroundColor = .white
           button.layer.cornerRadius = 35
           button.setTitle("", for: .normal)
           button.layer.borderWidth = 5
           button.layer.borderColor = UIColor.white.cgColor
           button.translatesAutoresizingMaskIntoConstraints = false
           button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
           return button
    }()
    
    // MARK: - Initialization
    init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.startCamera()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopCamera()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        setupPreviewLayer()
        view.addSubview(captureButton)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupPreviewLayer() {
        previewLayer = AVCaptureVideoPreviewLayer(session: viewModel.cameraHandler.session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let previewLayer = previewLayer {
            view.layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    private func setupBindings() {
        viewModel.onPhotoCaptured = { [weak self] image in
            guard let self = self else { return }
            self.NavigateToPreview(image: image)
        }
        
        viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            presentAlert(title: "Error", message: error.localizedDescription)
        }
        
        viewModel.onFaceDetectionError = { [weak self] error in
            guard let self = self else { return }
            presentAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    // MARK: - Actions
    @objc private func capturePhoto() {
        viewModel.capturePhoto()
    }
    
    private func NavigateToPreview(image: UIImage) {
        let previewVC = PreviewViewController(image: image)
        previewVC.delegate = self.presentingViewController as? SDKDelegate
        self.present(previewVC, animated: true, completion: nil)
    }
}
