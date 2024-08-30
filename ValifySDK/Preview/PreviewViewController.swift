//
//  PreviewViewController.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import UIKit

import UIKit

class PreviewViewController: UIViewController {
    // MARK: - Properties
    private let viewModel: PreviewViewModel
    private let imageView = UIImageView()
    private let approveButton = UIButton(type: .system)
    private let recaptureButton = UIButton(type: .system)
    
    // MARK: - Initializer
    init(image: UIImage) {
        self.viewModel = PreviewViewModel(image: image)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = viewModel.image
        view.addSubview(imageView)
        
        approveButton.translatesAutoresizingMaskIntoConstraints = false
        approveButton.setTitle("Approve", for: .normal)
        view.addSubview(approveButton)
        
        recaptureButton.translatesAutoresizingMaskIntoConstraints = false
        recaptureButton.setTitle("Recapture", for: .normal)
        view.addSubview(recaptureButton)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.33),
            
            approveButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            approveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            recaptureButton.topAnchor.constraint(equalTo: approveButton.bottomAnchor, constant: 20),
            recaptureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        approveButton.addTarget(self, action: #selector(approveButtonTapped), for: .touchUpInside)
        recaptureButton.addTarget(self, action: #selector(recaptureButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func approveButtonTapped() {
        viewModel.approvePhoto()
    }
    
    @objc private func recaptureButtonTapped() {
        viewModel.recapturePhoto()
    }
}

// MARK: - PreviewViewModelDelegate
extension PreviewViewController: PreviewViewModelDelegate {
    func didApprovePhoto() {
        // Handle what happens after photo is approved
        dismiss(animated: true, completion: nil)
    }
    
    func didRecapturePhoto() {
        dismiss(animated: true, completion: nil)
    }
}
