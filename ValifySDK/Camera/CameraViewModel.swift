//
//  CameraViewModel.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import AVFoundation
import UIKit

class CameraViewModel: NSObject {
    // MARK: - Properties
    private(set) var cameraHandler: CameraHandler

    // Callback closures for UI updates
    var onError: ((Error) -> Void)? {
        didSet {
            cameraHandler.onError = onError
        }
    }
    var onFaceDetectionError: ((Error) -> Void)? {
        didSet {
            cameraHandler.onFaceDetectionError = onFaceDetectionError
        }
    }
    var onPhotoCaptured: ((UIImage) -> Void)? {
        didSet {
            cameraHandler.onPhotoCaptured = onPhotoCaptured
        }
    }

    // MARK: - Initialization
    init(cameraHandler: CameraHandler) {
        self.cameraHandler = cameraHandler
        super.init()
    }

    func startCamera() {
        cameraHandler.startSession()
    }

    func stopCamera() {
        cameraHandler.stopSession()
    }

    func capturePhoto() {
        cameraHandler.capturePhoto()
    }
}
