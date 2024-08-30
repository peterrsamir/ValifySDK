//
//  CameraViewController.swift
//  ValifySDK
//
//  Created by Peter Samir on 29/08/2024.
//

import UIKit
import AVFoundation

public class CameraViewController: BaseViewController {

    @IBOutlet weak var captureButton: UIButton!
    private let viewModel: CameraViewModel

    // MARK: - init
    public init(viewModel: CameraViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "CameraViewController", bundle: Bundle(for: CameraViewController.self))
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.setupCamera()
    }
    
    private func setupViewModel() {
        // Handle errors from ViewModel
        viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            self.presentAlert(title: "Error", message: error.localizedDescription, actionTitle: "OK", actionHandler:  { [weak self] in
                self?.dismiss(animated: true)
                self?.viewModel.navigateToSettings()
            }) { [weak self] in
                self?.dismiss(animated: true)
            }
        }
        
//         Handle photo capture
        viewModel.onPhotoCaptured = { [weak self] image in
            guard let self = self else { return }
            let previewVC = PreviewViewController(image: image)
            self.present(previewVC, animated: true, completion: nil)
        }
    }
    
    /// Configure the preview layer
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let previewLayer = viewModel.videoPreviewLayer {
            previewLayer.frame = view.bounds
            view.layer.insertSublayer(previewLayer, at: 0)
        }
    }

    @IBAction func capturePhoto(_ sender: UIButton) {
        viewModel.capturePhoto()
    }
}
