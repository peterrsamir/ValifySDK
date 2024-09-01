//
//  CameraViewModel.swift
//  ValifySDK
//
//  Created by Peter Samir on 30/08/2024.
//

import UIKit
import AVFoundation

//public class CameraViewModel {
//    private let cameraHandler: CameraHandler
//    
//    // Callbacks
//    var onError: ((Error) -> Void)? {
//        didSet {
//            cameraHandler.onError = onError
//        }
//    }
//    var onFaceDetectionError: ((Error) -> Void)? {
//        didSet {
//            cameraHandler.onFaceDetectionError = onFaceDetectionError
//        }
//    }
//    var onPhotoCaptured: ((UIImage) -> Void)? {
//        didSet {
//            cameraHandler.onPhotoCaptured = onPhotoCaptured
//        }
//    }
//
//    var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
//        return cameraHandler.videoPreviewLayer
//    }
//
//    public init(cameraHandler: CameraHandler) {
//        self.cameraHandler = cameraHandler
//        cameraHandler.onError = onError
//        cameraHandler.onPhotoCaptured = onPhotoCaptured
//        cameraHandler.onFaceDetectionError = onFaceDetectionError
//        cameraHandler.setupFaceDetection()
//        setupCamera()
//    }
//
//    func setupCamera() {
//        cameraHandler.setupCamera()
//    }
//
//    func capturePhoto() {
//        cameraHandler.capturePhoto()
//    }
//}
