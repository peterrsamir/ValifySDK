//
//  PreviewViewController.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import UIKit

class PreviewViewController: BaseViewController {
    // MARK: - Properties
//    private let viewModel: PreviewViewModel
    @IBOutlet weak var imageView: UIImageView!
    private let selectedImage: UIImage!
    public weak var delegate: SDKDelegate?
    
    // MARK: - Initializer
    init(image: UIImage) {
        self.selectedImage = image
        super.init(nibName: nil, bundle: getSDKBundle())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.imageView.image = selectedImage
    }
    // MARK: - Actions
    @IBAction func recaptureButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func approveButtonAction(_ sender: Any) {
        // Handle what happens after photo is approved
        self.delegate?.sdkDidFinish(with: self.imageView)
        self.presentingViewController?
            .presentingViewController?.dismiss(animated: true)
    }
}
