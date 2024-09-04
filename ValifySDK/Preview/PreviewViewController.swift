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
    weak var delegate: SDKDelegate?
    private let selectedImage: UIImage!
    
    // MARK: - UI Elements
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var recaptureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Recapture", for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.cornerRadius = 8
        button.addTarget(self,
                         action: #selector(recaptureButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Approve", for: .normal)
        button.backgroundColor = UIColor.systemIndigo
        button.setTitleColor(.white, for: .normal)
        button.cornerRadius = 8
        button.addTarget(self, action: #selector(approveButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    // MARK: - Initializer
    init(image: UIImage) {
        self.selectedImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - View Lifecycle
    override func loadView() {
        super.loadView()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Add subviews
        view.addSubview(imageView)
        self.imageView.image = selectedImage
        view.addSubview(buttonStackView)
        
        // Add buttons to the stack view
        buttonStackView.addArrangedSubview(recaptureButton)
        buttonStackView.addArrangedSubview(approveButton)
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            // ImageView Constraints
            imageView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.68662),
            
            // Button Stack View Constraints
            buttonStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.055),
            buttonStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 8),
            buttonStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -8),
            buttonStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -32),
        ])
    }
    
    // MARK: - Actions
    @objc private func recaptureButtonAction() {
        dismiss(animated: true)
    }
    
    @objc private func approveButtonAction() {
        self.delegate?.sdkDidFinish(with: self.imageView)
        self.presentingViewController?
            .presentingViewController?.dismiss(animated: true)
    }
}
