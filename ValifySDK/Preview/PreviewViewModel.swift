//
//  PreviewViewModel.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import Foundation

import UIKit

protocol PreviewViewModelDelegate: AnyObject {
    func didApprovePhoto()
    func didRecapturePhoto()
}

public class PreviewViewModel {
    // MARK: - Properties
    let image: UIImage
    weak var delegate: PreviewViewModelDelegate?
    
    // MARK: - Initializer
    public init(image: UIImage) {
        self.image = image
    }
    
    // MARK: - Actions
    func approvePhoto() {
        // Implement logic to handle photo approval
        // This could be saving the photo, uploading, etc.
        delegate?.didApprovePhoto()
    }
    
    func recapturePhoto() {
        // Inform the delegate that recapture is requested
        delegate?.didRecapturePhoto()
    }
}
