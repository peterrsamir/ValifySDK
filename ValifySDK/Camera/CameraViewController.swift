//
//  CameraViewController.swift
//  ValifySDK
//
//  Created by Peter Samir on 29/08/2024.
//

import UIKit
import AVFoundation
import MLKitVision
import MLKitFaceDetection

public class CameraViewController: BaseViewController {

    @IBOutlet weak var captureButton: UIButton!
    private let viewModel = CameraViewModel(cameraHandler: CameraHandler())
    
    // MARK: - init
//    public init(viewModel: CameraViewModel) {
//        self.viewModel = viewModel
////        super.init(nibName: "CameraViewController", bundle: getSDKBundle())
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.setupCamera()
    }
    
//    public override func viewWillAppear(_ animated: Bool) {
//        
//    }
//    public override func viewWillDisappear(_ animated: Bool) {
//        <#code#>
//    }
    
    private func setupViewModel() {
        // Handle errors from ViewModel
        viewModel.onError = { [weak self] error in
            guard let self = self else { return }
            self.presentAlert(title: "Error", message: error.localizedDescription, actionTitle: "OK", actionHandler:  { [weak self] in
                self?.dismiss(animated: true)
            }) { [weak self] in
                self?.dismiss(animated: true)
            }
        }
        
        viewModel.onFaceDetectionError = { [weak self] error in
            self?.presentAlert(title: "Error", message: error.localizedDescription)
        }
        
//         Handle photo capture
        viewModel.onPhotoCaptured = { [weak self] image in
            guard let self = self else { return }
            let previewVC = PreviewViewController(image: image)
            previewVC.delegate = self.presentingViewController as? SDKDelegate
            self.present(previewVC, animated: true, completion: nil)
        }
    }
    
    /// Configure the preview layer
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        DispatchQueue.main.async { [weak self] in
            if let previewLayer = self?.viewModel.videoPreviewLayer {
                previewLayer.frame = self?.view?.bounds ?? CGRect()
                self?.view.layer.insertSublayer(previewLayer, at: 0)
            }
        }
    }

    @IBAction func capturePhoto(_ sender: UIButton) {
        viewModel.capturePhoto()
    }
}
